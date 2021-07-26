%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(controller_leader).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%%---------------------------------------------------------------------
%% Records & defintions
%%---------------------------------------------------------------------
-define(ControllerLeaderTime,30).

%% --------------------------------------------------------------------
-export([start_local_etcd/2,
	 start_host_controller/0]).


%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start_local_etcd(ClusterName,Cookie)->
    application:set_env([{etcd,[{is_leader,true}]}]),
    ok=application:start(etcd),
    timer:sleep(2000),
    {atomic,ok}=etcd:cluster_info_create(ClusterName,Cookie),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

start_host_controller()->
    host_controller:start(),
    [{running,R},{missing,M}]=host_controller:status_hosts(),
    {R,M}.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
