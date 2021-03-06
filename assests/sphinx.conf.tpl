####################################################################
# This file is automatically generated by the SphinxSearch Plugin
#
#  WARNING: YOUR DATABASE PASSWORD/USERNAME ARE CONTAINED IN THIS FILE!!!!
#
# -@author mcuhq
####################################################################


#create an offset from the `{ss_prefix}discussion`
#notice this: 0 as title ...this is key to not select dups

source {ss_prefix}main_comment
{
    type            = mysql
    sql_host        = {sql_host}
    sql_user        = {sql_user}
    sql_pass        = {sql_pass}
    sql_db          = {sql_db}
    {sql_sock}
    sql_port        = 3306    #optional, default is 3306

    sql_query_pre   = SET NAMES utf8
    sql_query_pre   = REPLACE INTO {db_prefix}sph_counter SELECT 1, MAX(c.CommentID +1) FROM {db_prefix}Comment as c
    sql_query       = SELECT (c.CommentID +1 + (SELECT MAX(d.DiscussionID) FROM {db_prefix}Discussion as d)), c.CommentID as docid, 1 as isComment,\
            c.Body as body, UNIX_TIMESTAMP(c.DateInserted) as docdateinserted,\
\
            0 as title, d.CountComments as CountComments, d.CountViews as CountViews,\
\
			cat.CategoryID as catid, cat.PermissionCategoryID as catpermid,\
\
            u.Name as user, u.UserID as UserID\
\
            FROM {db_prefix}Comment as c\
\
            INNER JOIN {db_prefix}Discussion as d ON c.DiscussionID = d.DiscussionID\
            INNER JOIN {db_prefix}User as u ON c.InsertUserID = u.UserID\
	    INNER JOIN {db_prefix}Category as cat ON d.CategoryID = cat.CategoryID\
\
            WHERE (c.CommentID +1) <=( SELECT max_doc_id FROM {db_prefix}sph_counter WHERE counter_id=1 )\

	sql_field_string = user #don't require sql call to get username when filtring by user on the main search page

	sql_attr_uint = UserID
	sql_attr_uint = docid
	sql_attr_uint = catid
        sql_attr_bigint = catpermid #so results respect user permissions (must be signed!)
	sql_attr_timestamp = docdateinserted
        sql_attr_uint = CountViews
        sql_attr_uint = CountComments
        sql_attr_uint = isComment        			#distinguishes between a discussion/comment


}

source {ss_prefix}delta_comment : {ss_prefix}main_comment
{

    sql_query_pre = SET NAMES utf8

    sql_query   = SELECT  (c.CommentID +1 + (SELECT MAX(d.DiscussionID) FROM {db_prefix}Discussion as d)), c.CommentID as docid, 1 as isComment,\
            c.Body as body, UNIX_TIMESTAMP(c.DateInserted) as docdateinserted,\
\
            0 as title, d.CountComments as CountComments, d.CountViews as CountViews,\
\
			cat.CategoryID as catid, cat.PermissionCategoryID as catpermid,\
\
            u.Name as user, u.UserID as UserID\
\
            FROM {db_prefix}Comment as c\
\
            INNER JOIN {db_prefix}Discussion as d ON c.DiscussionID = d.DiscussionID\
            INNER JOIN {db_prefix}User as u ON c.InsertUserID = u.UserID\
            INNER JOIN {db_prefix}Category as cat ON d.CategoryID = cat.CategoryID\
\
            WHERE (c.CommentID +1) > (SELECT max_doc_id FROM {db_prefix}sph_counter WHERE counter_id=1)\

}

#this source selects the discussion body  and its related info, exactly like the `{ss_prefix}comments` does.
#the discussion body is refered to as a comment to fit with the rest of the naming scheme
#yes, there are duplicate attributes stored, but the two sources MUST match columns(see MYSQL UNION)


source {ss_prefix}main_discussion
{
    type            = mysql
    sql_host        = {sql_host}
    sql_user        = {sql_user}
    sql_pass        = {sql_pass}
    sql_db          = {sql_db}
    {sql_sock}
    sql_port        = 3306    #optional, default is 3306

    sql_query_pre   = SET NAMES utf8
    sql_query_pre   = REPLACE INTO {db_prefix}sph_counter SELECT 2, MAX(d.DiscussionID) FROM {db_prefix}Discussion as d
    sql_query       = SELECT  d.DiscussionID, d.DiscussionID as docid, 0 as isComment,\
            d.Body as body, UNIX_TIMESTAMP(d.DateInserted) as docdateinserted,\
\
            d.Name as title, d.CountComments as CountComments, d.CountViews as CountViews,\
\
			d.CategoryID as catid, cat.PermissionCategoryID as catpermid,\
\
            u.Name as user, u.UserID as UserID\
\
            FROM {db_prefix}Discussion as d\
\
            INNER JOIN {db_prefix}Category as cat ON d.CategoryID = cat.CategoryID\
            INNER  JOIN {db_prefix}User as u ON d.InsertUserID = u.UserID \
\
            WHERE (d.DiscussionID) <= (SELECT max_doc_id FROM {db_prefix}sph_counter WHERE counter_id=2)\

	sql_field_string = user #don't require sql call to get username when filtring by user on the main search page

	sql_attr_uint = UserID
	sql_attr_uint = docid
	sql_attr_uint = catid
        sql_attr_bigint = catpermid #so results respect user permissions (must be signed!)
	sql_attr_timestamp = docdateinserted
        sql_attr_uint = CountViews
        sql_attr_uint = CountComments
        sql_attr_uint = isComment        			#distinguishes between a discussion/comment

}


source {ss_prefix}delta_discussion : {ss_prefix}main_discussion
{
    sql_query_pre = SET NAMES utf8
    sql_query = SELECT  d.DiscussionID, d.DiscussionID as docid, 0 as isComment,\
                         d.Body as body, UNIX_TIMESTAMP(d.DateInserted) as docdateinserted,\
\
            d.Name as title, d.CountComments as CountComments, d.CountViews as CountViews,\
\
			d.CategoryID as catid, cat.PermissionCategoryID as catpermid,\
\
            u.Name as user, u.UserID as UserID\
\
            FROM {db_prefix}Discussion as d\
\
            INNER JOIN {db_prefix}Category as cat ON d.CategoryID = cat.CategoryID\
            INNER  JOIN {db_prefix}User as u ON d.InsertUserID = u.UserID \
\
			WHERE (d.DiscussionID) > (SELECT max_doc_id FROM {db_prefix}sph_counter WHERE counter_id=2)\

}

index {ss_prefix}main
{
    source          = {ss_prefix}main_comment
    source          = {ss_prefix}main_discussion
    path            = {data_path}{ss_prefix}main
    docinfo         = extern
    charset_type    = {charset_type} #For more charsets, for Arabic, Persian, Italian, etc forums, please see: http://sphinxsearch.com/wiki/doku.php?id=charset_tables
}
index {ss_prefix}delta : {ss_prefix}main
{
    source          = {ss_prefix}delta_comment
    source          = {ss_prefix}delta_discussion
    path            = {data_path}{ss_prefix}delta
}

index vanilla
{
    type            =  distributed
    local           =  {ss_prefix}main
    local           =  {ss_prefix}delta


    #index settings
    morphology      = none
    dict            = crc
    min_stemming_len = 1
    min_word_len    = 2
    min_prefix_len  = 0
    min_infix_len   = 0
    enable_star     = 0
    ngram_len       = 0
    html_strip      = 0
    ondisk_dict     = 0
    inplace_enable  = 0
    expand_keywords = 0
    # 'utf-8' defaults for English and Russian
    charset_table = 0..9, A..Z->a..z, _, a..z, \
                    U+410..U+42F->U+430..U+44F, U+430..U+44F


}

indexer
{
    #indexer settings
    mem_limit       = 32M
    max_iops        = 0
    max_iosize      = 0
    write_buffer    = 1M
    max_file_field_buffer = 8M
}

searchd
{
    port            = {searchd_port}
    log             = {log_path}
    query_log       = {query_path}
    pid_file        = {PID_path}


    #settings
    read_timeout    = 5
    client_timeout  = 360
    max_children    = 0
    max_matches     = 1000
    read_buffer     = 1M
    workers         = fork
    thread_stack    = 64K
    expansion_limit = 0
    prefork_rotation_throttle = 0

    compat_sphinxql_magics = 0 # the future is now
}

# --eof--