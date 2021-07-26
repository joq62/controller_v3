all:
#	service
	rm -rf ebin/*;
	rm -rf src/*.beam *.beam  test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config *.log catalog;
	erlc -o ebin src/*.erl;
	echo Done
doc_gen:
	echo glurk not implemented
unit_test:
	rm -rf ebin/* src/*.beam *.beam test_src/*.beam test_ebin;
	rm -rf  *~ */*~  erl_cra*;
	rm -rf *_specs *_config *.log;
#	support
	cp ../support/src/support.app ebin;
	erlc -o ebin ../support/src/*.erl;
#	service
	cp src/controller.app ebin;
	erlc -o ebin src/*.erl;
#	etcd
	cp ../etcd/src/etcd.app ebin;
	erlc -o ebin ../etcd/src/*.erl;	
#	test application
	mkdir test_ebin;
	cp test_src/*.app test_ebin;
	erlc -o test_ebin test_src/*.erl;
	erl -pa ebin -pa test_ebin\
	    -setcookie abc\
	    -sname test_controller\
	    -run unit_test start_test test_src/test.config
