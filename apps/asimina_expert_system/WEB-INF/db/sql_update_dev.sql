---------------- Ahsan 23 Sep 2024 ----------------
update es_queries set distinct_keys_query="select p.id from ##CATALOG_DB##.catalogs c, ##CATALOG_DB##.products p where p.catalog_id = c.id and c.site_id = ##site_id## and (##catalog_type## = 'all' OR c.catalog_type = ##catalog_type##)" where name='products';
---------------- End ----------------