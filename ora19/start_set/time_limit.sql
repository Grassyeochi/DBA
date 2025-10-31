-- undo resource 크기 제한
-- sql 실행 시간 제한

exec dbms_resource_manager.create_pending_area();

begin
          dbms_resource_manager.update_plan_directive(
          plan=>'DAYTIME',
          group_or_subplan=>'ONLINE_USERS',
    new_undo_poll=> 200000,      
    new_max_est_exec_time => 120 );

exec dbms_resource_manager.submit_pending_area();
