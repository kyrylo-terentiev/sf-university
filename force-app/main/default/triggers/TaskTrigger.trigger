trigger TaskTrigger on Account (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
) {
    TriggerDispatcher.run(new TaskTriggerHandler(), 'TaskTrigger');
}