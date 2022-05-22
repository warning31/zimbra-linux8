echo -e [*] INFO : Configuring Rate Limit Sending Message and Reject Unlisted Domain
echo ""
echo "Manual Process"
echo -e "-------------------------------------------------------------------------"
echo -e "touch /tmp/policyd.sql"
echo -e "echo 'delete from "policy_groups" where id=100;' > /tmp/policyd.sql"
echo -e "echo 'delete from "policy_group_members" where id=100;' >> /tmp/policyd.sql"
echo -e "echo 'delete from "policies" where id=100;' >> /tmp/policyd.sql"
echo -e "echo 'delete from "policy_members" where id=100;' >> /tmp/policyd.sql"
echo -e "echo 'delete from "access_control" where id=100;' >> /tmp/policyd.sql"
echo -e "echo 'delete from "policies" where id=101;' >> /tmp/policyd.sql"
echo -e "echo 'delete from "policy_members" where id=101;' >> /tmp/policyd.sql"
echo -e "echo 'delete from "policy_members" where id=102;' >> /tmp/policyd.sql"
echo -e "echo 'delete from "quotas" where id=101;' >> /tmp/policyd.sql"
echo -e "echo 'delete from "quotas_limits" where id=101;' >> /tmp/policyd.sql"
echo -e "echo 'insert into "policy_groups" values(100,'list_domain',0,0);' >> /tmp/policyd.sql"
echo -e "echo 'insert into "policy_group_members" values(100,100,'@topalnarenciye.com.tr',0,0);' >> /tmp/policyd.sql"
echo -e "echo 'insert into "policies" values(100,'Reject Unlisted Domain',20,'Reject Unlisted Domain',0);' >> /tmp/policyd.sql"
echo -e "echo 'insert into "policy_members" values(100,100,'!%list_domain','!%list_domain',0,0);' >> /tmp/policyd.sql"
echo -e "echo 'insert into "access_control" values(100,100,'Reject Unlisted Domain','REJECT','Sorry,  you are not authorized to sending email','Reject Unlisted Domain',0);' >> /tmp/policyd.sql"
echo -e "echo 'insert into "policies" values(101,'Rate Limit Sending Message',21,'Rate Limit Sending Message',0);' >> /tmp/policyd.sql"
echo -e "echo 'insert into "policy_members" values(101,101,'%list_domain','!%list_domain',0,0);' >> /tmp/policyd.sql"
echo -e "echo 'insert into "policy_members" values(102,101,'!%list_domain','any',0,0);' >> /tmp/policyd.sql"
echo -e "echo 'insert into "quotas" values(101,101,'Rate Limit Sending Message','Sender:user@domain',3600,'DEFER','Max sending email have been full at last 3600s',0,'Rate Limit Sending Message',0);' >> /tmp/policyd.sql"
echo -e "echo 'insert into "quotas_limits" values(101,101,'MessageCount',300,'Rate Limit',0);' >> /tmp/policyd.sql"
echo -e 'su - zimbra -c "sqlite3 /opt/zimbra/data/cbpolicyd/db/cbpolicyd.sqlitedb < /tmp/policyd.sql"'
echo -e 'su - zimbra -c "zmcbpolicydctl restart"'
echo -e "-------------------------------------------------------------------------"
echo "Press key Enter for configure"
read presskey

touch /tmp/policyd.sql
echo "delete from 'policy_groups' where id=100;" > /tmp/policyd.sql
echo "delete from 'policy_group_members' where id=100;" >> /tmp/policyd.sql
echo "delete from 'policies' where id=100;" >> /tmp/policyd.sql
echo "delete from 'policy_members' where id=100;" >> /tmp/policyd.sql
echo "delete from 'access_control' where id=100;" >> /tmp/policyd.sql
echo "delete from 'policies' where id=101;" >> /tmp/policyd.sql
echo "delete from 'policy_members' where id=101;" >> /tmp/policyd.sql
echo "delete from 'policy_members' where id=102;" >> /tmp/policyd.sql
echo "delete from 'quotas' where id=101;" >> /tmp/policyd.sql
echo "delete from 'quotas_limits' where id=101;" >> /tmp/policyd.sql
echo "insert into 'policy_groups' values(100,'list_domain',0,0);" >> /tmp/policyd.sql
echo "insert into 'policy_group_members' values(100,100,'@topalnarenciye.com.tr',0,0);" >> /tmp/policyd.sql
echo "insert into 'policies' values(100,'Reject Unlisted Domain',20,'Reject Unlisted Domain',0);" >> /tmp/policyd.sql
echo "insert into 'policy_members' values(100,100,'!%list_domain','!%list_domain',0,0);" >> /tmp/policyd.sql
echo "insert into 'access_control' values(100,100,'Reject Unlisted Domain','REJECT','Sorry,  you are not authorized to sending email','Reject Unlisted Domain',0);" >> /tmp/policyd.sql
echo "insert into 'policies' values(101,'Rate Limit Sending Message',21,'Rate Limit Sending Message',0);" >> /tmp/policyd.sql
echo "insert into 'policy_members' values(101,101,'%list_domain','!%list_domain',0,0);" >> /tmp/policyd.sql
echo "insert into 'policy_members' values(102,101,'!%list_domain','any',0,0);" >> /tmp/policyd.sql
echo "insert into 'quotas' values(101,101,'Rate Limit Sending Message','Sender:user@domain',3600,'DEFER','Max sending email has been full at last 3600s',0,'Rate Limit Sending Message',0);" >> /tmp/policyd.sql
echo "insert into 'quotas_limits' values(101,101,'MessageCount',300,'Rate Limit',0);" >> /tmp/policyd.sql
su - zimbra -c "sqlite3 /opt/zimbra/data/cbpolicyd/db/cbpolicyd.sqlitedb < /tmp/policyd.sql"
su - zimbra -c "zmcbpolicydctl restart"
