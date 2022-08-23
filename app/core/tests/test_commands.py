"""
Test custom Django managment commands.
"""

from unittest.mock import patch

# Erreur possible de récupérer lors de la connextion à la BDD
from psycopg2 import OperationalError as Psycopg2Error

from django.core.management import call_command
# Erreur possible de récupérer lors de la connextion à la BDD
from django.db.utils import OperationalError
from django.test import SimpleTestCase


# mock du comportement de la database
@patch('core.management.commands.wait_for_db.Command.check')
class CommandTest(SimpleTestCase):
    """ Test commands. """

    def test_wait_for_df_ready(self, patched_check):
        """Test waiting for database if database ready"""
        # simulation d'un retour True
        patched_check.return_value = True

        call_command('wait_for_db')

        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """Test waiting for database when getting OperationalError."""

        # simulation d'une boucle de tentative de connections
        # 2 premières réponses --> Psycopg2Error
        # 3 tentatives suivantes --> OperationalError]
        # dernière tentative réussie
        patched_check.side_effect = [Psycopg2Error] * 2 + \
            [OperationalError] * 3 + [True]

        call_command('wait_for_db')

        self.assertEqual(patched_check.call_count, 6)
        patched_check.assert_called_with(databases=['default'])
