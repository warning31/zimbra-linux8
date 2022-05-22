PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE policies (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	Name			VARCHAR(255) NOT NULL,

	Priority		SMALLINT NOT NULL,

	Description		TEXT,

	Disabled		SMALLINT NOT NULL DEFAULT '0'

);
INSERT INTO policies VALUES(1,'Default',0,'Default System Policy',0);
INSERT INTO policies VALUES(2,'Default Outbound',0,'Default Outbound System Policy',0);
INSERT INTO policies VALUES(3,'Default Inbound',10,'Default Inbound System Policy',0);
INSERT INTO policies VALUES(4,'Default Internal',20,'Default Internal System Policy',0);
INSERT INTO policies VALUES(5,'Test',50,'Test policy',0);
CREATE TABLE policy_members (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	PolicyID		INT8,

	/* 
		Format of key: 
		NULL = any
		a.b.c.d/e = IP address with optional /e
		@domain = domain specification, 
		%xyz = xyz group, 
		abc@domain = abc user specification

		all options support negation using !<key>
	*/
	Source			TEXT,
	Destination		TEXT,

	Comment			VARCHAR(1024),

	Disabled		SMALLINT NOT NULL DEFAULT '0',

	FOREIGN KEY (PolicyID) REFERENCES policies(ID)
);
INSERT INTO policy_members VALUES(1,1,NULL,NULL,NULL,0);
INSERT INTO policy_members VALUES(2,2,'%internal_domains','!%internal_domains',NULL,0);
INSERT INTO policy_members VALUES(3,3,'!%internal_domains','%internal_domains',NULL,0);
INSERT INTO policy_members VALUES(4,4,'%internal_domains','%internal_domains',NULL,0);
INSERT INTO policy_members VALUES(5,5,'%internal_domains',NULL,NULL,0);
CREATE TABLE policy_groups (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	Name			VARCHAR(255) NOT NULL,


	Disabled		SMALLINT NOT NULL DEFAULT '0',

	Comment			VARCHAR(1024),


	UNIQUE (Name)
);
INSERT INTO policy_groups VALUES(2,'internal_domains',0,NULL);
CREATE TABLE policy_group_members (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	PolicyGroupID		INT8,

	/* Format of member: a.b.c.d/e = ip,  @domain = domain, %xyz = xyz group, abc@domain = abc user */
	Member			VARCHAR(255) NOT NULL,
	

	Disabled		SMALLINT NOT NULL DEFAULT '0',
	Comment			VARCHAR(1024),


	FOREIGN KEY (PolicyGroupID) REFERENCES policy_groups(ID)
);
INSERT INTO policy_group_members VALUES(2,2,'@green.local',0,NULL);
CREATE TABLE session_tracking (
	Instance		VARCHAR(255),
	QueueID			VARCHAR(255),

	UnixTimestamp		BIGINT NOT NULL,

	ClientAddress		VARCHAR(64),
	ClientName		VARCHAR(255),
	ClientReverseName	VARCHAR(255),

	Protocol		VARCHAR(255),

	EncryptionProtocol	VARCHAR(255),
	EncryptionCipher	VARCHAR(255),
	EncryptionKeySize	VARCHAR(255),

	SASLMethod		VARCHAR(255),
	SASLSender		VARCHAR(255),
	SASLUsername		VARCHAR(255),

	Helo			VARCHAR(255),

	Sender			VARCHAR(255),

	Size			UNSIGNED BIG INT,

	RecipientData		TEXT,  /* Policy state information */

	UNIQUE (Instance)
);
CREATE TABLE access_control (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	PolicyID		INT8,

	Name			VARCHAR(255) NOT NULL,

	Verdict			VARCHAR(255),
	Data			TEXT,


	Comment			VARCHAR(1024),

	Disabled		SMALLINT NOT NULL DEFAULT '0',

	FOREIGN KEY (PolicyID) REFERENCES policies(ID)
);
CREATE TABLE accounting (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	PolicyID		INT8,
	
	Name			VARCHAR(255) NOT NULL,

	/* Tracking Options */
	Track			VARCHAR(255) NOT NULL,  /* Format:   <type>:<spec>

					      SenderIP - This takes a bitmask to mask the IP with. A good default is /24 

					      Sender & Recipient - Either "user@domain" (default), "user@" or "@domain" for the entire 
					      		email addy or email addy domain respectively. 
					   */

	/* Period over which to account traffic */
	AccountingPeriod		SMALLINT NOT NULL,  /* 0 - Track by day, 1 - Track by week, 2 - Track by month */

	/* Limits for this period */
	MessageCountLimit		UNSIGNED BIG INT,  /* Limit is in Kbyte, NULL means no limit */
	MessageCumulativeSizeLimit	UNSIGNED BIG INT,  /* LImit is in Kbyte, NULL means no limit */

	/* Verdict if limits are exceeded */
	Verdict			VARCHAR(255), /* Verdict when limit is exceeded */
	Data			TEXT, /* Data sent along with verdict */
	
	LastAccounting		SMALLINT NOT NULL DEFAULT '0',
		
	Comment			VARCHAR(1024),
	
	Disabled		SMALLINT NOT NULL DEFAULT '0',

	FOREIGN KEY (PolicyID) REFERENCES policies(ID)
);
CREATE TABLE accounting_tracking (

	AccountingID		INT8,
	TrackKey		VARCHAR(512),
	PeriodKey		VARCHAR(512),

	/* Last time this record was update */
	LastUpdate		UNSIGNED BIG INT,  /* NULL means not updated yet */

	MessageCount		UNSIGNED BIG INT,
	MessageCumulativeSize	UNSIGNED BIG INT,  /* Counter is in Kbyte */
	
	UNIQUE (AccountingID,TrackKey,PeriodKey),
	FOREIGN KEY (AccountingID) REFERENCES accounting(ID)
);
CREATE TABLE amavis_rules (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	PolicyID		INT8,

	Name			VARCHAR(255) NOT NULL,

/*
Mode of operation (the _m columns):

	This is done with the _m column names

	0 - Inherit
	1 - Merge  (only valid for lists)
	2 - Overwrite

*/


	/* Bypass options */
	bypass_virus_checks	SMALLINT,
	bypass_virus_checks_m	SMALLINT NOT NULL DEFAULT '0',

	bypass_banned_checks	SMALLINT,
	bypass_banned_checks_m	SMALLINT NOT NULL DEFAULT '0',

	bypass_spam_checks	SMALLINT,
	bypass_spam_checks_m	SMALLINT NOT NULL DEFAULT '0',

	bypass_header_checks	SMALLINT,
	bypass_header_checks_m	SMALLINT NOT NULL DEFAULT '0',


	/* Anti-spam options: NULL = inherit */
	spam_tag_level		FLOAT,
	spam_tag_level_m	SMALLINT NOT NULL DEFAULT '0',

	spam_tag2_level		FLOAT,
	spam_tag2_level_m	SMALLINT NOT NULL DEFAULT '0',

	spam_tag3_level		FLOAT,
	spam_tag3_level_m	SMALLINT NOT NULL DEFAULT '0',

	spam_kill_level		FLOAT,
	spam_kill_level_m	SMALLINT NOT NULL DEFAULT '0',

	spam_dsn_cutoff_level	FLOAT,
	spam_dsn_cutoff_level_m	SMALLINT NOT NULL DEFAULT '0',

	spam_quarantine_cutoff_level	FLOAT,
	spam_quarantine_cutoff_level_m	SMALLINT NOT NULL DEFAULT '0',

	spam_modifies_subject	SMALLINT,
	spam_modifies_subject_m	SMALLINT NOT NULL DEFAULT '0',

	spam_tag_subject	VARCHAR(255),  /* _SCORE_ is the score, _REQD_ is the required score */
	spam_tag_subject_m	SMALLINT NOT NULL DEFAULT '0',

	spam_tag2_subject	VARCHAR(255),
	spam_tag2_subject_m	SMALLINT NOT NULL DEFAULT '0',

	spam_tag3_subject	VARCHAR(255),
	spam_tag3_subject_m	SMALLINT NOT NULL DEFAULT '0',


	/* General checks: NULL = inherit */
	max_message_size	BIGINT,  /* in Kbyte */
	max_message_size_m	SMALLINT NOT NULL DEFAULT '0',

	banned_files		TEXT,
	banned_files_m		SMALLINT NOT NULL DEFAULT '0',


	/* Whitelist & blacklist */
	sender_whitelist	TEXT,
	sender_whitelist_m	SMALLINT NOT NULL DEFAULT '0',

	sender_blacklist	TEXT,
	sender_blacklist_m	SMALLINT NOT NULL DEFAULT '0',


	/* Admin notifications */
	notify_admin_newvirus	VARCHAR(255),
	notify_admin_newvirus_m	SMALLINT NOT NULL DEFAULT '0',

	notify_admin_virus	VARCHAR(255),
	notify_admin_virus_m	SMALLINT NOT NULL DEFAULT '0',

	notify_admin_spam	VARCHAR(255),
	notify_admin_spam_m	SMALLINT NOT NULL DEFAULT '0',

	notify_admin_banned_file	VARCHAR(255),
	notify_admin_banned_file_m	SMALLINT NOT NULL DEFAULT '0',

	notify_admin_bad_header	VARCHAR(255),
	notify_admin_bad_header_m	SMALLINT NOT NULL DEFAULT '0',


	/* Quarantine options */
	quarantine_virus	VARCHAR(255),
	quarantine_virus_m	SMALLINT NOT NULL DEFAULT '0',

	quarantine_banned_file	VARCHAR(255),
	quarantine_banned_file_m	SMALLINT NOT NULL DEFAULT '0',

	quarantine_bad_header	VARCHAR(255),
	quarantine_bad_header_m	SMALLINT NOT NULL DEFAULT '0',

	quarantine_spam		VARCHAR(255),
	quarantine_spam_m	SMALLINT NOT NULL DEFAULT '0',


	/* Interception options */
	bcc_to			VARCHAR(255),
	bcc_to_m		SMALLINT NOT NULL DEFAULT '0',


	Comment			VARCHAR(1024),

	Disabled		SMALLINT NOT NULL DEFAULT '0',

	FOREIGN KEY (PolicyID) REFERENCES policies(ID)
);
INSERT INTO amavis_rules VALUES(1,1,'Default system amavis policy',NULL,0,1,2,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,100000,2,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0,NULL,0);
CREATE TABLE quotas (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	PolicyID		INT8,
	
	Name			VARCHAR(255) NOT NULL,

	/* Tracking Options */
	Track			VARCHAR(255) NOT NULL,  /* Format:   <type>:<spec>

					      SenderIP - This takes a bitmask to mask the IP with. A good default is /24 

					      Sender & Recipient - Either "user@domain" (default), "user@" or "@domain" for the entire 
					      		email addy or email addy domain respectively. 
					   */

	/* Period over which this policy is valid,  this is in seconds */
	Period			UNSIGNED BIG INT,

	Verdict			VARCHAR(255),
	Data			TEXT,
	
	LastQuota		SMALLINT NOT NULL DEFAULT '0',
		
	Comment			VARCHAR(1024),
	
	Disabled		SMALLINT NOT NULL DEFAULT '0',

	FOREIGN KEY (PolicyID) REFERENCES policies(ID)
);
INSERT INTO quotas VALUES(3,2,'Rate_Limit_Outbound','Recipient:@domain',3600,'DEFER','Deferring: Too many messages from sender in last 60 minutes','Deferring: Too many messages from sender in last 60 minutes','Deferring: Too many messages from sender in last 60 minutes',0);
CREATE TABLE quotas_limits (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	QuotasID		INT8,

	Type			VARCHAR(255),  /* "MessageCount" or "MessageCumulativeSize" */
	CounterLimit		UNSIGNED BIG INT,

	Comment			VARCHAR(1024),

	Disabled		SMALLINT NOT NULL DEFAULT '0',

	FOREIGN KEY (QuotasID) REFERENCES quotas(ID)
);
INSERT INTO quotas_limits VALUES(4,3,'MessageCount',50,'',0);
CREATE TABLE quotas_tracking (

	QuotasLimitsID		INT8,
	TrackKey		VARCHAR(512),

	/* Last time this record was update */
	LastUpdate		UNSIGNED BIG INT,  /* NULL means not updated yet */

	Counter			NUMERIC(10,4),
	
	UNIQUE (QuotasLimitsID,TrackKey),
	FOREIGN KEY (QuotasLimitsID) REFERENCES quotas_limits(ID)
);
CREATE TABLE checkhelo (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	PolicyID		INT8,

	Name			VARCHAR(255) NOT NULL,


	/* Blacklisting, we want to reject people impersonating us */
	UseBlacklist			SMALLINT,  /* Checks blacklist table */
	BlacklistPeriod			UNSIGNED BIG INT,  /* Period to keep the host blacklisted for, if not set or 0
						    the check will be live */	

	/* Random helo prevention */
	UseHRP				SMALLINT,  /* Use helo randomization prevention */
	HRPPeriod			UNSIGNED BIG INT,  /* Period/window we check for random helo's */
	HRPLimit			UNSIGNED BIG INT,  /* Our limit for the number of helo's is this */

	/* RFC compliance options */
	RejectInvalid			SMALLINT,  /* Reject invalid HELO */
	RejectIP			SMALLINT,  /* Reject if HELO is an IP */
	RejectUnresolvable		SMALLINT,  /* Reject unresolvable HELO */


	Comment			VARCHAR(1024),

	Disabled		SMALLINT NOT NULL DEFAULT '0',

	FOREIGN KEY (PolicyID) REFERENCES policies(ID)
);
CREATE TABLE checkhelo_blacklist (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	Helo			VARCHAR(255) NOT NULL,

	Comment			VARCHAR(1024),

	Disabled		SMALLINT NOT NULL DEFAULT '0',

	UNIQUE (Helo)
);
INSERT INTO checkhelo_blacklist VALUES(1,'127.0.0.1','Blacklist hosts claiming to be 127.0.0.1',0);
INSERT INTO checkhelo_blacklist VALUES(2,'[127.0.0.1]','Blacklist hosts claiming to be [127.0.0.1]',0);
INSERT INTO checkhelo_blacklist VALUES(3,'localhost','Blacklist hosts claiming to be localhost',0);
INSERT INTO checkhelo_blacklist VALUES(4,'localhost.localdomain','Blacklist hosts claiming to be localhost.localdomain',0);
CREATE TABLE checkhelo_whitelist (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	Source			VARCHAR(512) NOT NULL,  /* Valid format is:    SenderIP:a.b.c.d[/e]  */

	Comment			VARCHAR(1024),

	Disabled		SMALLINT NOT NULL DEFAULT '0',

	UNIQUE (Source)
);
CREATE TABLE checkhelo_tracking (
	Address			VARCHAR(64) NOT NULL,
	Helo			VARCHAR(255) NOT NULL,
	LastUpdate		UNSIGNED BIG INT NOT NULL,

	UNIQUE (Address,Helo)
);
CREATE TABLE checkspf (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	PolicyID		INT8,

	Name			VARCHAR(255) NOT NULL,

	/* Do we want to use SPF?  1 or 0 */
	UseSPF				SMALLINT,
	/* Reject when SPF fails */
	RejectFailedSPF			SMALLINT,
	/* Add SPF header */
	AddSPFHeader			SMALLINT,

	Comment			VARCHAR(1024),

	Disabled		SMALLINT NOT NULL DEFAULT '0',

	FOREIGN KEY (PolicyID) REFERENCES policies(ID)
);
CREATE TABLE greylisting (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	PolicyID		INT8,

	Name			VARCHAR(255) NOT NULL,


	/* General greylisting settings */
	UseGreylisting			SMALLINT,  /* Actually use greylisting */
	GreylistPeriod			UNSIGNED BIG INT,  /* Period in seconds to greylist for */

	/* Record tracking */
	Track				VARCHAR(255) NOT NULL,  /* Format:   <type>:<spec>
							SenderIP - This takes a bitmask to mask the IP with, A good default is /24
						*/

	/* Bypass greylisting: sender+recipient level */
	GreylistAuthValidity		UNSIGNED BIG INT,  /* Period for which last authenticated greylist entry is valid for.
						    This effectively bypasses greylisting for the second email a sender
						    sends a recipient. */
	GreylistUnAuthValidity		UNSIGNED BIG INT,  /* Same as above but for unauthenticated entries */


	/* Auto-whitelisting: sending server level */
	UseAutoWhitelist		SMALLINT,  /* Use auto-whitelisting */
	AutoWhitelistPeriod		UNSIGNED BIG INT,  /* Period to look back to find authenticated triplets */
	AutoWhitelistCount		UNSIGNED BIG INT,  /* Count of authenticated triplets after which we auto-whitelist */
	AutoWhitelistPercentage		UNSIGNED BIG INT,  /* Percentage of at least Count triplets that must be authenticated
							   before auto-whitelisting. This changes the behaviour or Count */

	/* Auto-blacklisting: sending server level */
	UseAutoBlacklist		SMALLINT,  /* Use auto-blacklisting */
	AutoBlacklistPeriod		UNSIGNED BIG INT,  /* Period to look back to find unauthenticated triplets */
	AutoBlacklistCount		UNSIGNED BIG INT,  /* Count of authenticated triplets after which we auto-whitelist */
	AutoBlacklistPercentage		UNSIGNED BIG INT,  /* Percentage of at least Count triplets that must be authenticated
							   before auto-whitelisting. This changes the behaviour or Count */

	Comment			VARCHAR(1024),

	Disabled		SMALLINT NOT NULL DEFAULT '0',

	FOREIGN KEY (PolicyID) REFERENCES policies(ID)
);
CREATE TABLE greylisting_whitelist (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	Source			VARCHAR(255) NOT NULL,  /* Either CIDR  a.b.c.d, a.b.c.d/x, or reversed   host*-*.whatever.com */

	Comment			VARCHAR(1024),

	Disabled		SMALLINT NOT NULL DEFAULT '0',

	UNIQUE (Source)
);
CREATE TABLE greylisting_autowhitelist (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	TrackKey		VARCHAR(512) NOT NULL,

	Added			UNSIGNED BIG INT NOT NULL,
	LastSeen		UNSIGNED BIG INT NOT NULL,

	Comment			VARCHAR(1024),

	UNIQUE (TrackKey)
);
CREATE TABLE greylisting_autoblacklist (
	ID			INTEGER PRIMARY KEY AUTOINCREMENT,

	TrackKey		VARCHAR(512) NOT NULL,

	Added			UNSIGNED BIG INT NOT NULL,

	Comment			VARCHAR(1024),

	UNIQUE (TrackKey)
);
CREATE TABLE greylisting_tracking (

	TrackKey		VARCHAR(512) NOT NULL, /* The address really, masked with whatever */
	Sender			VARCHAR(255) NOT NULL,
	Recipient		VARCHAR(255) NOT NULL,

	FirstSeen		UNSIGNED BIG INT NOT NULL,
	LastUpdate		UNSIGNED BIG INT NOT NULL,

	Tries			UNSIGNED BIG INT NOT NULL,  /* Authentication tries */
	Count			UNSIGNED BIG INT NOT NULL,  /* Authenticated count */

	UNIQUE(TrackKey,Sender,Recipient)
);
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence VALUES('policies',6);
INSERT INTO sqlite_sequence VALUES('policy_members',5);
INSERT INTO sqlite_sequence VALUES('policy_groups',2);
INSERT INTO sqlite_sequence VALUES('policy_group_members',10);
INSERT INTO sqlite_sequence VALUES('amavis_rules',1);
INSERT INTO sqlite_sequence VALUES('quotas',3);
INSERT INTO sqlite_sequence VALUES('quotas_limits',4);
INSERT INTO sqlite_sequence VALUES('checkhelo_blacklist',4);
CREATE INDEX session_tracking_idx1 ON session_tracking (QueueID,ClientAddress,Sender);
CREATE INDEX session_tracking_idx2 ON session_tracking (UnixTimestamp);
CREATE INDEX accounting_tracking_idx1 ON accounting_tracking (LastUpdate);
CREATE INDEX quotas_tracking_idx1 ON quotas_tracking (LastUpdate);
CREATE INDEX checkhelo_tracking_idx1 ON checkhelo_tracking (LastUpdate);
CREATE INDEX greylisting_tracking_idx1 ON greylisting_tracking (LastUpdate,Count);
COMMIT;