name             'mssqlserver_alwayson_tests'
maintainer       'YOUR_COMPANY_NAME'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Tests for mssqlserver_alwayson cookbooks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'
depends      'mssqlserver'
depends			 'mssqlserver_alwayson_tests'