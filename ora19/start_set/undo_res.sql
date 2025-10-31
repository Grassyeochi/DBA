-- undo resource를 200mb로 제한

exec dbms_resource_manager.create_pending_area();

begin
    dbms_resource_manager.update_plan_directive(
    plan=>'DAYTIME',
    group_or_subplan=>'ONLINE_USERS',
    new_undo_pool=> 200000);
end;
/

exec dbms_resource_manager.submit_pending_area();
