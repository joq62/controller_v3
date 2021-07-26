%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Manage Computers
%%% Install Cluster
%%% Install cluster
%%% Data-{HostId,Ip,SshPort,Uid,Pwd}
%%% available_hosts()-> [{HostId,Ip,SshPort,Uid,Pwd},..]
%%% install_leader_host({HostId,Ip,SshPort,Uid,Pwd})->ok|{error,Err}
%%% cluster_status()->[{running,WorkingNodes},{not_running,NotRunningNodes}]

%%% Created : 
%%% -------------------------------------------------------------------
-module(controller).  
-behaviour(gen_server).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
-define(HostFile,"glurk").
-define(HostConfigDir,"g").
-define(GitHostConfigCmd,"g").
%% --------------------------------------------------------------------
%% Key Data structures
%% 
%% --------------------------------------------------------------------
-record(state, {w_hosts,w_pods,w_cluster}).

%% --------------------------------------------------------------------
%% Definitions 
%% --------------------------------------------------------------------
-define(ControllerStatusInterval,1*10*1000).
%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------





% OaM related
-export([
	 status_interval/2,

	 load_config/0,
	 read_config/0,
	 status_hosts/0,
	 status_slaves/0,
	 start_masters/1,
	 start_slaves/3,
	 start_slaves/1,
	 running_hosts/0,
	 running_slaves/0,
	 missing_hosts/0,
	 missing_slaves/0
	]).

-export([
	 create/4,
	 install/0,
	 available_hosts/0

	]).


-export([boot/0,
	 start_app/5,
	 stop_app/4,
	 app_status/2
	]).

-export([start/0,
	 stop/0,
	 ping/0
	]).

%% gen_server callbacks
-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).


%% ====================================================================
%% External functions
%% ====================================================================

%% Asynchrounus Signals

boot()->
    application:start(?MODULE).

%% Gen server functions

start()-> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
stop()-> gen_server:call(?MODULE, {stop},infinity).


%%---------------------------------------------------------------
status_interval(HostsStatus,ClusterStatus)->
  gen_server:cast(?MODULE,{status_interval,HostsStatus,ClusterStatus}).
create(NumMasters,Hosts,Name,Cookie)->
    gen_server:call(?MODULE, {create,NumMasters,Hosts,Name,Cookie},infinity).
delete(Name)->
    gen_server:call(?MODULE, {delete,Name},infinity).    



%%---------------------------------------------------------------
running_hosts()->
       gen_server:call(?MODULE, {running_hosts},infinity).
running_slaves()->
       gen_server:call(?MODULE, {running_slaves},infinity).
missing_hosts()->
       gen_server:call(?MODULE, {missing_hosts},infinity).
missing_slaves()->
       gen_server:call(?MODULE, {missing_slaves},infinity).

load_config()-> 
    gen_server:call(?MODULE, {load_config},infinity).
read_config()-> 
    gen_server:call(?MODULE, {read_config},infinity).
status_hosts()-> 
    gen_server:call(?MODULE, {status_hosts},infinity).
status_slaves()-> 
    gen_server:call(?MODULE, {status_slaves},infinity).

start_masters(HostIds)->
    gen_server:call(?MODULE, {start_masters,HostIds},infinity).
start_slaves(HostIds)->
    gen_server:call(?MODULE, {start_slaves,HostIds},infinity).

start_slaves(HostId,SlaveNames,ErlCmd)->
    gen_server:call(?MODULE, {start_slaves,HostId,SlaveNames,ErlCmd},infinity).
    
%% old
install()-> 
    gen_server:call(?MODULE, {install},infinity).
available_hosts()-> 
    gen_server:call(?MODULE, {available_hosts},infinity).

start_app(ApplicationStr,Application,CloneCmd,Dir,Vm)-> 
    gen_server:call(?MODULE, {start_app,ApplicationStr,Application,CloneCmd,Dir,Vm},infinity).

stop_app(ApplicationStr,Application,Dir,Vm)-> 
    gen_server:call(?MODULE, {stop_app,ApplicationStr,Application,Dir,Vm},infinity).

app_status(Vm,Application)-> 
    gen_server:call(?MODULE, {app_status,Vm,Application},infinity).
ping()-> 
    gen_server:call(?MODULE, {ping},infinity).

%%-----------------------------------------------------------------------

%%----------------------------------------------------------------------


%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: 
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%
%% --------------------------------------------------------------------
init([]) ->
    io:format("Start init ~p~n",[{time(),?FUNCTION_NAME,?MODULE,?LINE}]), 
    spawn(fun()->controller_status_interval() end),
    io:format("Successful starting of server ~p~n",[{time(),?FUNCTION_NAME,?MODULE,?LINE}]), 
   {ok, #state{}}.
    
%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (aterminate/2 is called)
%% --------------------------------------------------------------------
handle_call({app_status,Vm,Application},_From,State) ->
    Reply=cluster_lib:app_status(Vm,Application),
    {reply, Reply, State};

handle_call({ping},_From,State) ->
    Reply={pong,node(),?MODULE},
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% -------------------------------------------------------------------
handle_cast({status_interval,HostsStatus,ClusterStatus}, State) ->
    io:format(" ~p~n",[{date(),time()}]),
    io:format("HostsStatus ~p~n",[HostsStatus]),
    io:format("ClusterStatus ~p~n~n~n",[ClusterStatus]),
    NewState=State,
    spawn(fun()->controller_status_interval() end), 
   {noreply, NewState};
handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{?MODULE,?LINE,Msg}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info(Info, State) ->
    io:format("unmatched match info ~p~n",[{?MODULE,?LINE,Info}]),
    {noreply, State}.


%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Internal functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
controller_status_interval()->
  %  io:format("Start ~p~n",[{?FUNCTION_NAME,?MODULE,?LINE}]),
    timer:sleep(?ControllerStatusInterval),
    HostsInfo=case rpc:call(node(),iaas,status_all_hosts,[],1*5000) of
		  {badrpc,Err}->
		      {error,[badrpc,Err]};
		  HostsStatus->
		      HostsStatus
	      end,
    ClustersInfo=case rpc:call(node(),iaas,status_all_clusters,[],1*5000) of
		     {badrpc,Err2}->
			 {error,[badrpc,Err2]};
		     ClusterStatus->
			 ClusterStatus
		 end,
    
    rpc:cast(node(),controller,status_interval,[HostsInfo,ClustersInfo]).
 %   io:format("End ~p~n",[{?FUNCTION_NAME,?MODULE,?LINE}]).
%    ok=rpc:cast(node(),controller,status_interval,[Hosts,Clusters]).

%% --------------------------------------------------------------------
%% Function: 
%% Description:
%% Returns: non
%% --------------------------------------------------------------------
