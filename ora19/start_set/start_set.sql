-- undo resource를 200mb로 제한
-- sql 최대실행 시간 설정 
-- 병렬도 설정


exec dbms_resource_manager.create_pending_area();

begin
    dbms_resource_manager.update_plan_directive(
    plan=>'DAYTIME',
    group_or_subplan=>'ONLINE_USERS',
    new_undo_pool=> 200000,
    new_max_est_exec_time => 120     
    new_parallel_degree_limit_p1 =>2);
end;
/

exec dbms_resource_manager.submit_pending_area();
