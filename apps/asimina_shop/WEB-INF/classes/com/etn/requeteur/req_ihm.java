package com.etn.requeteur;

import com.etn.Client.Impl.ClientSql;
import com.etn.beans.Contexte;
import com.etn.lang.ResultSet.ArraySet;
import com.etn.lang.ResultSet.Set;
import com.etn.sql.escape;

/**
 * Source pour jdk 1.5...
 * Sinon supprimer <...>
 */
import java.util.Calendar;
import java.util.Vector;
import java.util.HashMap;

public class req_ihm {

    /***************************************	COMMON FUNCTION - BEGIN	*********************************************/
    /***********************************	SCREEN QUERY / CREVIEW	- BEGIN	*************************************/
    /* give the context table
     * must return column nom_table_ihm and dbtable
     * */
    public String getListContexte(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, java.util.HashMap h) {
        boolean isAdmin = false;
        if (request != null) {
            javax.servlet.http.HttpSession session = request.getSession(true);
            if (session.getValue("isAdmin") != null) {
                if (session.getValue("isAdmin").equals("1")) {
                    isAdmin = true;
                }
            }

        }

        String sql = "select distinct nom_table_ihm, nom_table_ihm as dbtable,serveur.nom, dbnom from catalog join serveur on serveur.id = catalog.serveur where type1=0 and nom_table_ihm <>'' " + (isAdmin ? "" : " and type_contexte=0 ") + "  group by 1 order by 1";
        //String sql = "select distinct nom_table_ihm, nom_table_ihm as dbtable from catalog where type1=0 and nom_table_ihm <>'' "+(isAdmin?"":" and type_contexte=0 ")+"  group by 1 order by 1";
        return (sql);
    }

    /* give the field filter
     * must return column champ, granEquipement, nomlogique,concat( dbnom,'.',dbtable) as val,filtrable,dbtable,nom_table_ihm
     * */
    public String getFieldFilter(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, java.util.HashMap h, String type1, String filtre_liste, boolean filtre_table_u) {

        /* DEFAULT QUERY REQUETE
        String sqlFiltre = "SELECT distinct c.champ, replace(c.granEquipement,'.',',') granEquipement, c.nomlogique,concat( dbnom,'.',dbtable) as val, ";
        sqlFiltre+="  c.filtrable,dbtable,nom_table_ihm FROM catalog c ";
        sqlFiltre+=" WHERE c.filtrable & "+Types.filtre +" = "+Types.filtre+" and champ not in('specialite','type') ";

        if( filtre_table_u ){
        if(! type1.equals("") ){
        sqlFiltre+= " and dbtable = '"+com.etn.util.Substitue.dblCote(type1)+"'";
        }

        }

        if(! filtre_liste.equals("") ){
        sqlFiltre+=" and nomlogique like '%"+com.etn.util.Substitue.dblCote(filtre_liste)+"%'";
        }


        sqlFiltre+="  order by dbtable,c.champ ";*/

        String sqlFiltre = "";
        sqlFiltre = "SELECT distinct c.champ, replace(c.granEquipement,'.',',') granEquipement, c.nomlogique,concat( dbnom,'.',dbtable) as val, ";
        sqlFiltre += "  c.filtrable,dbtable,nom_table_ihm, valbdd, valihm, typeDB, serveur.id FROM catalog c ";
        sqlFiltre += " JOIN serveur ON serveur.id = c.serveur";
        sqlFiltre += " WHERE c.filtrable & " + Types.filtre + " = " + Types.filtre + "  ";


        if (filtre_table_u) {
            if (!type1.equals("")) {
                sqlFiltre += " and dbtable = " + escape.cote(type1) + "";
            }

        }



        String c = getContexte(Etn, type1);

        if (h.get("creview_table") != null) { //if tree, take only the table (nom_table_ihm) selected
            c = escape.cote("" + h.get("creview_table"));
            sqlFiltre += " and nom_table_ihm = " + c;
        } else {
            if (!c.equals("")) {
                sqlFiltre += " and dbtable in(" + c + ")";
            }
        }



        if (!filtre_liste.equals("")) {
            sqlFiltre += " and nomlogique like '%" + com.etn.util.Substitue.dblCote(filtre_liste) + "%'";
        }


        sqlFiltre += "  order by nom_table_ihm,c.champ ";//order by granEquipement desc


        return (sqlFiltre);
    }

    /* give the field filter
     * must return column champ, granEquipement, nomlogique,concat( dbnom,'.',dbtable) as val,filtrable,dbtable,nom_table_ihm
     * */
    public String getFieldCompteur(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, java.util.HashMap h, String type1, String compteur, int i_compteur, boolean filtre_table_u, String onglet) {

        String sqlCompteur = "SELECT " + (onglet.equalsIgnoreCase("champs") ? "	distinct c.nomlogique champ " : "	distinct case when unite<>'' then concat(unite,'(`',c.nomlogique,'`)') else c.nomlogique end champ ") + ","; //distinct concat(if(unite<>'',concat(unite,'('),'count('),'`',c.nomlogique,'`',if(unite<>'',')',')')) champ "
        sqlCompteur += "  c.champ champ2 ,c.nomlogique,nom_table_ihm as dbtable,nom_table_ihm, valbdd, valihm, typeDB, serveur.id,c.filtrable ";

        sqlCompteur += "  FROM catalog c ";
        sqlCompteur += " JOIN serveur ON serveur.id = c.serveur";
        sqlCompteur += " WHERE c.filtrable & " + Types.select + " ";

        //out.write("filtre_table_u="+filtre_table_u+"<br>");

        if (filtre_table_u) {
            if (!type1.equals("")) {
                sqlCompteur += " and dbtable = " + com.etn.sql.escape.cote(type1);
            }
        }

        String c = getContexte(Etn, type1);
        if (h.get("creview_table") != null) {
            c = escape.cote("" + h.get("creview_table"));
            sqlCompteur += " and nom_table_ihm = " + c;
        } else {
            if (!c.equals("")) {
                sqlCompteur += " and dbtable in(" + c + ")";
            }
        }

        if (!compteur.equalsIgnoreCase("")) {
            sqlCompteur += " and nomlogique like " + com.etn.sql.escape.cote("%" + compteur + "%");
        }

        sqlCompteur += " union ";
        sqlCompteur += " select formule as champ,nomkpi as champ2,nomkpi as nomlogique,'kpi' as dbtable,'kpi' as nom_table_ihm,'kpi' as valbdd,'kpi' as valihm,'0' as typeDB,0 as id,0 as filtrable ";
        sqlCompteur += " from kpi where constructeur ='" + type1 + "'";
        if (!compteur.equalsIgnoreCase("")) {
            sqlCompteur += " and nomkpi like " + com.etn.sql.escape.cote("%" + compteur + "%");
        }
        sqlCompteur += " and type = 'Compteur' ";
        sqlCompteur += " order by nom_table_ihm,nomlogique ";
        if (i_compteur != -1) {
            sqlCompteur += " limit " + i_compteur + "";
        }
        return (sqlCompteur);
    }

    public String getFieldAgregation(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, java.util.HashMap h, String type1, String equipement, int i_compteur, boolean filtre_table_u) {
        String sqlGroupe = "SELECT distinct c.champ, replace(c.granEquipement,'.',',') granEquipement, c.nomlogique, ";
        sqlGroupe += "  c.filtrable,dbtable,nom_table_ihm, valbdd, valihm, typeDB, serveur.id FROM catalog c ";
        sqlGroupe += " JOIN serveur ON serveur.id = c.serveur";
        sqlGroupe += " WHERE c.filtrable & " + Types.groupe + "  ";//order by granEquipement desc

        if (filtre_table_u) {
            if (!type1.equals("")) {
                sqlGroupe += " and dbtable = '" + com.etn.util.Substitue.dblCote(type1) + "'";
            }
        }

        String c = getContexte(Etn, type1);
        if (h.get("creview_table") != null) {
            c = escape.cote("" + h.get("creview_table"));
            sqlGroupe += " and nom_table_ihm = " + c;
        } else {

            if (!c.equals("")) {
                sqlGroupe += " and dbtable in(" + c + ")";
            }

        }

        if (!equipement.equalsIgnoreCase("")) {
            sqlGroupe += " and nomlogique like " + com.etn.sql.escape.cote("%" + equipement + "%");
            sqlGroupe += " order by dbtable,c.champ ";
        } else {
            sqlGroupe += " order by dbtable,c.champ ";
            sqlGroupe += " limit " + i_compteur + "";
        }
        return (sqlGroupe);
    }

    /***********************************	SCREEN QUERY / CREVIEW	- END	*************************************/
    /***********************************	TAB KPI (Query)	- BEGIN	*************************************/
    public String getSansFamilleKpi() {
        return ("--Sans famille de KPI--");
    }

    public String listKpi(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, java.util.HashMap h, String type1, String kpi1, String famille_kpi, int i_compteur) {
        String sqlKPI = "select nomkpi, typedb, formule from kpi ";
        if (!kpi1.equalsIgnoreCase("")) {
            sqlKPI += " where nomkpi like '%" + kpi1 + "%'";
            sqlKPI += " and constructeur ='" + type1 + "'";
            sqlKPI += " and type <> 'Compteur'";

            if (!famille_kpi.equals("")) {
                sqlKPI += " and lienkpi ='" + (famille_kpi.equals(getSansFamilleKpi()) ? "" : famille_kpi) + "'";
            }

            sqlKPI += " order by 1";
        } else {
            sqlKPI += " where constructeur ='" + type1 + "'";
            sqlKPI += " and type <> 'Compteur'";

            if (!famille_kpi.equals("")) {
                sqlKPI += " and lienkpi ='" + (famille_kpi.equals(getSansFamilleKpi()) ? "" : famille_kpi) + "'";
            }

            sqlKPI += " order by 1";
            sqlKPI += " limit " + i_compteur;
        }
        return (sqlKPI);
    }

    /***********************************	TAB KPI (Query)	- END	*************************************/
    /***********************************	SCREEN KPI (Administration)	- BEGIN	*************************************/
    public String familleKpi(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, java.util.HashMap h, String type1) {
        String sqlFamilleKPI = "select distinct if(lienkpi='','" + getSansFamilleKpi() + "',lienkpi) as lienkpi from kpi";
        sqlFamilleKPI += " where type <> 'Compteur'";
        sqlFamilleKPI += " and constructeur ='" + type1 + "'";
        sqlFamilleKPI += " order by 1";
        return (sqlFamilleKPI);
    }

    /***********************************	SCREEN KPI (Administration) - END	*************************************/
    public String listTdbListeRequete(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request) {
        String sqlTdb = "select distinct nom_tdb,id_tdb from tdb order by 1 ";
        return (sqlTdb);
    }

    /***********************************	NOT VISIBLE IN A SCREEN - BUILD OF FILTRE OF QUERY - BEGIN	*************************************/
    public String constructionFiltre(com.etn.beans.Contexte Etn, String w, String w2, String w3, String liste_diff, int i_diff, String type_elt) {

        /* QUERY BY DEFAULT
        String sql2="select distinct (nomlogique) as nomlogique,type,'' as date1,typeDB,valbdd,valihm,'' as diff  "+
        " from catalog inner join serveur o on( o.id = catalog.serveur ) "+
        " where catalog.techno = 0 and nomlogique in("+w+") and nomlogique <>'psdate' and filtrable > 0";
        if(!w2.equals("")){
        sql2+=" union select distinct (nomlogique) as nomlogique,type,'"+w3+"' as date1,typeDB,'','','' as diff  "+
        " from catalog inner join serveur o on( o.id = catalog.serveur ) "+
        " where catalog.techno = 0 and nomlogique ='psdate' and dbtable="+escape.cote(type_elt)+"  and filtrable > 0";
        }
        if( i_diff>0 ){
        sql2+=" union select distinct (nomlogique) as nomlogique,type,'' as date1,typeDB,valbdd,valihm,' not ' as diff  "+
        " from catalog inner join serveur o on( o.id = catalog.serveur ) "+
        " where catalog.techno = 0 and nomlogique in("+liste_diff+") and nomlogique <>'psdate'  and filtrable > 0";
        }*/



        String sql2 = "select distinct (nomlogique) as nomlogique,type,'' as date1,typeDB,valbdd,valihm,'' as diff  "
                + " from catalog inner join serveur o on( o.id = catalog.serveur ) "
                + " where catalog.techno = 0 and nomlogique in(" + w + ") and nomlogique <>'psdate' and filtrable > 0 ";// and and nomlogique not in(select distinct eqp from toptour2)"; //and filtrable & 32
        if (!w2.equals("")) {
            sql2 += " union select distinct (nomlogique) as nomlogique,'' type,'" + w3 + "' as date1,'' typeDB,'','','' as diff   "
                    + " from catalog inner join serveur o on( o.id = catalog.serveur ) "
                    + " where catalog.techno = 0 and nomlogique ='psdate' and nom_table_ihm='" + type_elt + "'";
        }
        if (i_diff > 0) {
            sql2 += " union select distinct (nomlogique) as nomlogique,type,'' as date1,typeDB,valbdd,valihm,' not ' as diff  "
                    + " from catalog inner join serveur o on( o.id = catalog.serveur ) "
                    + " where catalog.techno = 0 and nomlogique in(" + liste_diff + ") and nomlogique <>'psdate'  and filtrable > 0";
        }

        return (sql2);
    }

    /***********************************	NOT VISIBLE IN A SCREEN - BUILD OF FILTRE OF QUERY - END	*************************************/
    /***********************************	SCREEN PREDIFINED QUERY  BEGIN	*************************************/
    public String getOrigineCloud() {
        return ("concat(requete_name,' ', requete_desc)");
    }

    public String requeteCloud(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, java.util.HashMap h) {
        String origineCloud = getOrigineCloud();

        String sql = "select " + origineCloud + " clef, concat(requete_name,' ', requete_desc) as pp from requete where person_id=" + Etn.getId()
                + " or person_id <> " + Etn.getId() + " and partage=1 ";
        return (sql);
    }

    public String mesRequete(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, java.util.HashMap h, String table, String s, String id_tdb, String cloud_sql, String col, String ord) {



        String sql1 = " select distinct r.requete_name,r.requete_id, r.requete_desc,if(r.partage=0,'NON','OUI') as partage1,if(g.id_graph is null,'NON','OUI') as tdb,date_requete,cree_le,lance_le ";//if(r.aff_tdb=0,'NON','OUI') as tdb
        sql1 += " from requete r left join  graph_tdb g on ( r.requete_id = g.requete_id ) ";
        sql1 += " where r.person_id = " + Etn.getId() + " and r.requete_name like '" + s + "%' " + (table.equals("") ? "" : " and r.type_elt='" + table + "'") + " ";
        //sql1+=""+(id_tdb.equals("")?"":" and g.id_tdb='"+id_tdb+"'");

        if (id_tdb.equals("-1")) {
            sql1 += " and g.id_tdb is null ";
        } else {
            if (!id_tdb.equals("")) {
                sql1 += " and g.id_tdb='" + id_tdb + "'";
            }
        }
        sql1 += cloud_sql;
        //sql1+=" order by r.requete_name ";
        String orderBy = col + " " + ord;
        sql1 += " order by " + orderBy + " ";
        return (sql1);
    }

    public String listeTdb(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, java.util.HashMap h) {
        String sql = "select distinct requete_id,t2.nom_tdb from graph_tdb t,tdb t2 where t.id_tdb = t2.id_tdb order by 1 ";
        return (sql);
    }

    public String requetePartagees(com.etn.beans.Contexte Etn, javax.servlet.http.HttpServletRequest request, java.util.HashMap h, String table, String s, String id_tdb, String cloud_sql) {


        String sql2 = "select distinct r.requete_name, r.requete_id, r.requete_desc,concat(last_name,' ',first_name) as pers ";
        sql2 += " from person p,requete r left join  graph_tdb g on ( r.requete_id = g.requete_id ) ";
        sql2 += " where r.person_id <> " + Etn.getId() + " and r.partage=1 and r.requete_name like '" + s + "%'";
        sql2 += "" + (table.equals("") ? "" : " and r.type_elt='" + table + "'") + " ";
        //sql2+= ""+(id_tdb.equals("")?"":" and g.id_tdb='"+id_tdb+"'")+" ";
        if (id_tdb.equals("-1")) {
            sql2 += " and g.id_tdb is null ";
        } else {
            if (!id_tdb.equals("")) {
                sql2 += " and g.id_tdb='" + id_tdb + "'";
            }
        }
        sql2 += cloud_sql;
        sql2 += " and p.person_id = r.person_id";
        sql2 += " order by r.requete_name";
        return (sql2);
    }

    /***********************************	SCREEN PREDIFINED QUERY  END	*************************************/
    /***********************************	INBOX BEGIN	*************************************/
    public String sql_inbox(String user_id, String type1, String c) {
        String sql = "";

        /*en cours de traitement*/
        if (type1.equals("1")) {
            sql = "select " + (c.equals("inbox") ? "count(*) as nb" : "nom,date_r,r.id as id,sqlid,r.requete_id ");
            sql += " from requete_en_cours r left join thread_work t on r.id = t.id, requete r2 ";
            sql += " where r.requete_id = r2.requete_id ";
            sql += " and r.person_id=" + user_id;
            sql += " and fin is null ";
            sql += " and t.id is null and date_r >= curdate() ";
            sql += " order by date_r desc; ";
        }
        /*historique*///en cours de traitement
        if (type1.equals("2")) {

            sql = "select " + (c.equals("inbox") ? "count(*) as nb" : "id, requete_id,nom,date_r ") + "  from requete_en_cours where person_id=";
            sql += user_id;
            sql += " order by date_r desc";
        }

        return (sql);
    }

    /***********************************	INBOX END	*************************************/
    /***************************************	COMMON FUNCTION - END	*********************************************/
    public String getServeurTree(com.etn.beans.Contexte Etn, String context) {
        String joinTables = "";
        if (context != null && !context.equals("")) {
            joinTables = getContexteC(Etn, context);
        }
        String query = " select distinct serveur.nom, serveur.id as serverid";
        query += " from catalog";
        query += " join serveur on serveur.id = catalog.serveur";
        query += " where CONCAT(serveur, dbnom, dbtable) IN(" + joinTables + ")";
        query += " order by serveur.nom ";
        return query;
    }

    public String getDatabaseTree(com.etn.beans.Contexte Etn, String context, String parentServer) {
        String joinTables = "";
        if (context != null && !context.equals("")) {
            joinTables = getContexteC(Etn, context);
        }
        String query = " select distinct serveur.nom, serveur.id as serverid, dbnom";
        query += " from catalog";
        query += " join serveur on serveur.id = catalog.serveur";
        query += " where serveur.nom='" + parentServer + "'";
        query += " and CONCAT(serveur, dbnom, dbtable) IN(" + joinTables + ")";
        query += " order by serveur.nom,dbnom ";
        return query;
    }

    public String getTablesTree(com.etn.beans.Contexte Etn, String context) {
        String joinTables = "";
        if (context != null && !context.equals("")) {
            joinTables = getContexteC(Etn, context);
        }
        String query = " select distinct serveur.nom, serveur.id as serverid,  if( is_graph_table= 1,dbnom,'') dbnom, nom_table_ihm as dbtable, nom_table_ihm, hierarchical, is_graph_table, if( is_graph_table= 1,dbtable,'') as actual_table";
        query += " from catalog";
        query += " join serveur on serveur.id = catalog.serveur";
        //query += " where serveur.nom='"+parentServer+"' and dbnom='"+parentDb+"'";
        query += " where CONCAT(serveur, dbnom, dbtable) IN(" + joinTables + ")";
        query += " order by serveur.nom,dbnom,nom_table_ihm ";
        return query;
    }
    
    public String getTablesWithContext(com.etn.beans.Contexte Etn, String context) {
        String joinTables = "";
        if (context != null && !context.equals("")) {
            joinTables = getContexteC(Etn, context);
        }
        String query = " select distinct serveur.nom, serveur.id as serverid, dbnom, nom_table_ihm as dbtable, nom_table_ihm";
        query += " from catalog";
        query += " join serveur on serveur.id = catalog.serveur";
        //query += " where serveur.nom='"+parentServer+"' and dbnom='"+parentDb+"'";
        query += " where CONCAT(serveur, dbnom, dbtable) IN(" + joinTables + ")";
        query += " order by serveur.nom,dbnom,nom_table_ihm ";
        return query;
    }

    public String getSearchResultTree(com.etn.beans.Contexte Etn, String searchText, String type, String context) {
        String query = "";
        String c = getContexteC(Etn, context);
        if (type.equals("serveur")) {
            query = " select distinct serveur.nom";
            query += " from catalog";
            query += " join serveur on serveur.id = catalog.serveur";
            query += " where nom_table_ihm!=''";//(filtrable & 16 or filtrable & 32 )
            if (!c.equals("")) {
                query += " AND CONCAT(serveur, dbnom, dbtable) in(" + c + ")";
            }
            query += " AND ( dbnom LIKE '%" + searchText + "%' OR nom_table_ihm LIKE '%" + searchText + "%' OR nomlogique LIKE '%" + searchText + "%' ) ";
            //query += " AND nom_table_ihm!=''";
        } else if (type.equals("db")) {
            query = " select distinct serveur.nom, dbnom";
            query += " from catalog";
            query += " join serveur on serveur.id = catalog.serveur";
            query += " where nom_table_ihm!=''";//(filtrable & 16 or filtrable & 32 )
            if (!c.equals("")) {
                query += " AND CONCAT(serveur, dbnom, dbtable) in(" + c + ")";
            }
            query += "AND ( nom_table_ihm LIKE '%" + searchText + "%' OR nomlogique LIKE '%" + searchText + "%' )";
            //query += " AND nom_table_ihm!=''";
        } else if (type.equals("table")) {
            query = " select distinct serveur.nom, dbnom, nom_table_ihm as dbtable";
            query += " from catalog";
            query += " join serveur on serveur.id = catalog.serveur";
            query += " where nom_table_ihm!='' AND ( nomlogique LIKE '%" + searchText + "%' )";//(filtrable & 16 or filtrable & 32 )
            if (!c.equals("")) {
                query += " AND CONCAT(serveur, dbnom, dbtable) in(" + c + ")";
            }
            //query += " AND nom_table_ihm!=''";
        }
        return query;
    }

    public String getColumnNamesDrillDown(com.etn.beans.Contexte Etn, String tables) {
        String query = " select distinct nomlogique";
        query += " from catalog";
        query += " where (filtrable & 32 )";
        query += " AND CONCAT(serveur, dbnom, dbtable) in(" + tables + ")";
        
        //query += " AND nomlogique LIKE '%" + term + "%'";
        query += " order by nomlogique";
        //query += " LIMIT " + limit;
        return query;
    }

    public String getTableNamesDrillDown(com.etn.beans.Contexte Etn, String context, String nomlogiques) {
        String c = getContexteC(Etn, context);
        String query = " select distinct serveur, dbnom, dbtable";
        query += " from catalog";
        query += " where nomlogique in(" + nomlogiques + ")";
        if (!c.equals("")) {
            query += " AND CONCAT(serveur, dbnom, dbtable) in(" + c + ")";
        }
        //query += " AND nomlogique in(" + nomlogiques + ")";
        //query += " AND nomlogique LIKE '%" + term + "%'";
        query += " order by nomlogique";
        //query += " LIMIT " + limit;
        return query;
    }

    public String getColumnNamesFilter(com.etn.beans.Contexte Etn, String term, String limit, String context) {
        String c = getContexteC(Etn, context);
        String query = " select distinct nomlogique";
        query += " from catalog";
        query += " where (filtrable & 16 )";
        if (!c.equals("")) {
            query += " AND CONCAT(serveur, dbnom, dbtable) in(" + c + ")";
        }
        query += " AND nomlogique LIKE '%" + term + "%'";
        query += " order by nomlogique";
        query += " LIMIT " + limit;
        return query;
    }

    public String getFilterACObject(com.etn.beans.Contexte Etn, String column, String context) {
        String c = getContexteC(Etn, context);
        String query = " select distinct serveur.nom, serveur.id as serverid, dbnom, nom_table_ihm as dbtable, typeDB, nomlogique, filtrable, valbdd, valihm";
        query += " from catalog";
        query += " join serveur on serveur.id = catalog.serveur";
        query += " where nomlogique = '" + column + "'";
        //query += " where (filtrable & 16 or filtrable & 32 )";
        if (!c.equals("")) {
            query += " AND CONCAT(serveur, dbnom, dbtable) in(" + c + ")";
        }
        //query += " AND nomlogique = '"+column+"'";
        query += " LIMIT 1";
        return query;
    }

    public String getKpiData(com.etn.beans.Contexte Etn, String kpisForIn, String context) {
        String kpiQuery = "SELECT * FROM `kpi` WHERE `nomkpi` IN(" + kpisForIn + ") AND `constructeur`='" + context + "';";
        return kpiQuery;
    }

    public String getCatalogData(com.etn.beans.Contexte Etn, String valeursForIn) {
        String catalogQuery = "SELECT serveur.nom, serveur.id as serverid, dbnom, nom_table_ihm as dbtable, typeDB, nomlogique, filtrable FROM `catalog` JOIN serveur ON serveur.id = catalog.serveur WHERE `nomlogique` IN(" + valeursForIn + ") GROUP BY `nomlogique`;";
        return catalogQuery;
    }

    public String getRequeteIdFromName(com.etn.beans.Contexte Etn, String requete_name) {
        String requeteQuery = "SELECT `requete_id` FROM `requete` WHERE `requete_name`=" + escape.cote(requete_name) + ";";
        return requeteQuery;
    }

    public String getRequeteFromId(com.etn.beans.Contexte Etn, String requete_id) {
        String requeteQuery = "SELECT * FROM `requete` where requete_id =" + requete_id + ";";
        return requeteQuery;
    }

    public String getRequeteEnCours(com.etn.beans.Contexte Etn, String requete_id) {
        //String requeteQuery="SELECT * FROM requete_en_cours WHERE requete_id="+requete_id+ " ORDER BY id DESC LIMIT 1";
        String requeteQuery = "SELECT requete.requete_name as nom, requete.requete_desc, histo_requete.* ";
        requeteQuery += " FROM histo_requete ";
        requeteQuery += " JOIN requete ON requete.requete_id = histo_requete.requete_id";
        requeteQuery += " WHERE histo_requete.requete_id=" + requete_id + " ORDER BY cache_id DESC LIMIT 1";
        return requeteQuery;
    }
    
    public String requeteSaveUpdate(com.etn.beans.Contexte Etn, String requete_id, String requete_name, String requete_desc, int person_id, String valeurs, String filtres, String agregations_v, String agregations_h, String partage, String type_elt, String id_graph, String type_aff, String variables, String ordre, String having_col) {
    	return(requeteSaveUpdate(Etn, requete_id, requete_name, requete_desc,  person_id, valeurs, filtres, agregations_v, agregations_h, partage, type_elt,  id_graph, type_aff, variables, ordre, having_col,"") );
    }

    public String requeteSaveUpdate(com.etn.beans.Contexte Etn, String requete_id, String requete_name, String requete_desc, int person_id, String valeurs, String filtres, String agregations_v, String agregations_h, String partage, String type_elt, String id_graph, String type_aff, String variables, String ordre, String having_col,String vname) {
        String requeteQuery = "UPDATE `requete` SET `requete_name`=" + escape.cote(requete_name) +",`requete_desc`=" + escape.cote(requete_desc) + ",`person_id`=" + escape.cote("" + person_id) + ",`valeurs`=" + escape.cote(valeurs) + ",`filtres`=" + escape.cote(filtres) + ",`agregations_v`=" + escape.cote(agregations_v) + ",`agregations_h`=" + escape.cote(agregations_h) + ",`partage`=" + escape.cote(partage) + ",`type_elt`=" + escape.cote(type_elt) + "" + (id_graph.equals("") ? "" : ",`id_graph`=" + escape.cote(id_graph)) + ",`type_aff`=" + escape.cote(type_aff) + ",`variables`=" + escape.cote(variables) + ",`cree_le`=now(),`ordre`=" + escape.cote(ordre) + ",`having_col`=" + escape.cote(having_col) + ",vname="+escape.cote(vname);
        requeteQuery += " WHERE `requete_id`=" + requete_id + ";";
        return requeteQuery;
    }

    public String requeteSaveInsert(com.etn.beans.Contexte Etn, String requete_name, String requete_desc, int person_id, String valeurs, String filtres, String agregations_v, String agregations_h, String partage, String type_elt, String id_graph, String type_aff, String variables, String ordre, String having_col) {
    	return(requeteSaveInsert(Etn,requete_name,requete_desc,person_id,valeurs,filtres,agregations_v,agregations_h, partage, type_elt, id_graph, type_aff, variables, ordre,  having_col,""));
    }
    
    public String requeteSaveInsert(com.etn.beans.Contexte Etn, String requete_name, String requete_desc, int person_id, String valeurs, String filtres, String agregations_v, String agregations_h, String partage, String type_elt, String id_graph, String type_aff, String variables, String ordre, String having_col,String vname) {
        String requeteQuery = "INSERT INTO `requete` (`requete_name`,`requete_desc`,`person_id`,`valeurs`,`filtres`,`agregations_v`,`agregations_h`,`partage`,`type_elt`,`id_graph`,`type_aff`,`variables`,`cree_le`,`ordre`,`having_col`,vname)";
        requeteQuery += " VALUES (" + escape.cote(requete_name) + "," + escape.cote(requete_desc) + "," + escape.cote("" + person_id) + "," + escape.cote(valeurs) + "," + escape.cote(filtres) + "," + escape.cote(agregations_v) + "," + escape.cote(agregations_h) + "," + escape.cote(partage) + "," + escape.cote(type_elt) + "," + escape.cote(id_graph) + "," + escape.cote(type_aff) + "," + escape.cote(variables) + ",now()," + escape.cote(ordre) + "," + escape.cote(having_col) + ","+escape.cote(vname)+");";
        return requeteQuery;
    }

    public String requeteUpdateGraphTable(com.etn.beans.Contexte Etn, String requete_id, String graphTableSelectClause, String graphTableJoinClause, String graphTableWhereClause, String graphTableName, String graphTableServerId, String graphTableDbNom, String graphTableWhereColumns) {
        String requeteQuery ="UPDATE requete SET graph_select_clause='"+graphTableSelectClause+"',graph_join_clause='"+graphTableJoinClause+"',graph_where_clause="+com.etn.sql.escape.cote(graphTableWhereClause)+",graph_table_name='"+graphTableName+"',graph_table_server_id='"+graphTableServerId+"',graph_table_dbname='"+graphTableDbNom+"',graph_where_columns='"+graphTableWhereColumns+"'";
        requeteQuery+=" WHERE requete_id="+requete_id+";";
        return requeteQuery;
    }

    public String requeteGraphTableFields(com.etn.beans.Contexte Etn, String table, String dbnom, String server_id)
    {
        String query="SELECT champ, nomlogique, dbtable, graph_type, dbnom, serveur FROM catalog WHERE dbtable='"+table+"' AND dbnom='"+dbnom+"' AND serveur='"+server_id+"' AND graph_type!='' GROUP BY graph_type;";
        return query;
    }

    public String requeteGraphCriteriaNomlogique(com.etn.beans.Contexte Etn, String table, String dbnom, String server_id)
    {
        String query="SELECT nomlogique FROM catalog WHERE dbtable='"+table+"' AND dbnom='"+dbnom+"' AND serveur='"+server_id+"' AND graph_type='criteria';";
        return query;
    }

    public String requeteGraphGeneralNomlogique(com.etn.beans.Contexte Etn, String table, String dbnom, String server_id, String columnType)
    {
        String query="SELECT nomlogique FROM catalog WHERE dbtable='"+table+"' AND dbnom='"+dbnom+"' AND serveur='"+server_id+"' AND graph_type='"+columnType+"';";
        return query;
    }

    public String getValbddFromValihm(com.etn.beans.Contexte Etn, String valbdd) {
        String valbddQuery = "select valihm,serveur from catalog where valbdd=" + valbdd;
        return valbddQuery;
    }

    /*********************	les functions ou méthodes spécifiques au projet	*******************************/
    public String getTableContexte(com.etn.beans.Contexte Etn, String c) {
        String tables = "";
        com.etn.lang.ResultSet.Set rsTable = Etn.execute("select distinct dbtable from catalog where nom_table_ihm = '" + c + "'");
        while (rsTable.next()) {
            tables += (tables.equals("") ? "" : ",") + "'" + rsTable.value("dbtable") + "'";
        }
        return (tables);
    }

    public String getContexte(com.etn.beans.Contexte Etn, String type1) {
        String tables = "";

        type1 = getTableContexte(Etn, type1);
        if( type1.equals("") ){
        	type1="''";
        }
        com.etn.lang.ResultSet.Set rsTable = Etn.execute("select table1,table2 from jointure where (table1 in (" + type1 + ") or table2 in(" + type1 + ")) order by 1");

        while (rsTable.next()) {
            tables += (tables.equals("") ? "" : ",") + "'" + rsTable.value("table1") + "'";
            tables += (tables.equals("") ? "" : ",") + "'" + rsTable.value("table2") + "'";
        }


        return (tables);
    }

    /*********************	les functions ou méthodes spécifiques au projet	*******************************/
    public String getTableContexteC(com.etn.beans.Contexte Etn, String c) {
        String tables = "";
        com.etn.lang.ResultSet.Set rsTable = Etn.execute("select distinct CONCAT(serveur, dbnom, dbtable) as dbtable from catalog where nom_table_ihm = '" + c + "'");
        while (rsTable.next()) {
            tables += (tables.equals("") ? "" : ",") + "'" + rsTable.value("dbtable") + "'";
        }
        return (tables);
    }

    public String getContexteC(com.etn.beans.Contexte Etn, String type1) {
        String tables = "";

        type1 = getTableContexteC(Etn, type1);
        tables = type1;
        if( type1.equals("") ){
        	type1="''";
        }
        com.etn.lang.ResultSet.Set rsTable = Etn.execute("select table1, base1, db1,table2, base2, db2 from jointure where (CONCAT(db1, base1, table1) in (" + type1 + ") or CONCAT(db2, base2, table2) in(" + type1 + ")) order by 1");

        while (rsTable.next()) {
            tables += (tables.equals("") ? "" : ",") + "'" + rsTable.value("db1") + rsTable.value("base1") + rsTable.value("table1") + "'";
            tables += (tables.equals("") ? "" : ",") + "'" + rsTable.value("db2") + rsTable.value("base2") + rsTable.value("table2") + "'";
        }
        return (tables);
    }
}
