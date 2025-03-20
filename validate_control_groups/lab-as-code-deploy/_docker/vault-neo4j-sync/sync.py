import hvac
import neo4j
from neo4j import GraphDatabase
import logging
from datetime import datetime
import os
from typing import Dict, List, Any

class VaultToNeo4jSync:
    def __init__(self, vault_url: str, vault_token: str, neo4j_uri: str, neo4j_user: str, neo4j_password: str):
        # Initialize Vault client
        self.vault_client = hvac.Client(
            url=vault_url,
            token=vault_token
        )
        
        # Initialize Neo4j driver
        self.neo4j_driver = GraphDatabase.driver(
            neo4j_uri,
            auth=(neo4j_user, neo4j_password)
        )
        
        # Setup logging
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(logging.INFO)
        
    def get_vault_entities(self) -> List[Dict[str, Any]]:
        """Fetch all entities and their metadata from Vault"""
        try:
            # List all entities
            entities = self.vault_client.auth.list_entities()['data']['keys']
            entity_details = []
            
            for entity_name in entities:
                # Get detailed info for each entity
                entity_info = self.vault_client.auth.read_entity(entity_name)['data']
                entity_details.append(entity_info)
            
            return entity_details
        except Exception as e:
            self.logger.error(f"Error fetching Vault entities: {str(e)}")
            raise
    
    def get_vault_groups(self) -> List[Dict[str, Any]]:
        """Fetch all groups and their metadata from Vault"""
        try:
            groups = self.vault_client.auth.list_groups()['data']['keys']
            group_details = []
            
            for group_name in groups:
                group_info = self.vault_client.auth.read_group(group_name)['data']
                group_details.append(group_info)
            
            return group_details
        except Exception as e:
            self.logger.error(f"Error fetching Vault groups: {str(e)}")
            raise

    def sync_to_neo4j(self):
        """Sync Vault entities and relationships to Neo4j"""
        with self.neo4j_driver.session() as session:
            try:
                # Clear existing data
                session.run("MATCH (n) DETACH DELETE n")
                
                # Get Vault data
                entities = self.get_vault_entities()
                groups = self.get_vault_groups()
                
                # Create entity nodes
                for entity in entities:
                    session.run("""
                        CREATE (e:Entity {
                            id: $id,
                            name: $name,
                            created_time: $created_time,
                            last_update_time: $last_update_time,
                            policies: $policies
                        })
                    """, {
                        'id': entity['id'],
                        'name': entity['name'],
                        'created_time': entity.get('creation_time', ''),
                        'last_update_time': entity.get('last_update_time', ''),
                        'policies': ','.join(entity.get('policies', []))
                    })
                
                # Create group nodes
                for group in groups:
                    session.run("""
                        CREATE (g:Group {
                            id: $id,
                            name: $name,
                            created_time: $created_time,
                            last_update_time: $last_update_time,
                            policies: $policies
                        })
                    """, {
                        'id': group['id'],
                        'name': group['name'],
                        'created_time': group.get('creation_time', ''),
                        'last_update_time': group.get('last_update_time', ''),
                        'policies': ','.join(group.get('policies', []))
                    })
                
                # Create relationships
                for group in groups:
                    # Group to Entity relationships
                    for member_id in group.get('member_entity_ids', []):
                        session.run("""
                            MATCH (g:Group {id: $group_id})
                            MATCH (e:Entity {id: $entity_id})
                            CREATE (g)-[:CONTAINS]->(e)
                        """, {
                            'group_id': group['id'],
                            'entity_id': member_id
                        })
                    
                    # Group to Group relationships
                    for member_group_id in group.get('member_group_ids', []):
                        session.run("""
                            MATCH (g1:Group {id: $group_id})
                            MATCH (g2:Group {id: $member_group_id})
                            CREATE (g1)-[:INCLUDES]->(g2)
                        """, {
                            'group_id': group['id'],
                            'member_group_id': member_group_id
                        })
                
                self.logger.info("Successfully synced Vault data to Neo4j")
                
            except Exception as e:
                self.logger.error(f"Error syncing to Neo4j: {str(e)}")
                raise
            
    def close(self):
        """Close all connections"""
        self.neo4j_driver.close()

if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    # Get configuration from environment variables
    vault_url = os.getenv('VAULT_URL')
    vault_token = os.getenv('VAULT_TOKEN')
    neo4j_uri = os.getenv('NEO4J_URI')
    neo4j_user = os.getenv('NEO4J_USER')
    neo4j_password = os.getenv('NEO4J_PASSWORD')
    
    # Initialize and run sync
    sync = VaultToNeo4jSync(
        vault_url=vault_url,
        vault_token=vault_token,
        neo4j_uri=neo4j_uri,
        neo4j_user=neo4j_user,
        neo4j_password=neo4j_password
    )
    
    try:
        sync.sync_to_neo4j()
    finally:
        sync.close()