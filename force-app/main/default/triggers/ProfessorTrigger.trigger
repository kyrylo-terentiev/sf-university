trigger ProfessorTrigger on Professor__c (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
) {
    TriggerDispatcher.run(new ProfessorTriggerHandler(), 'ProfessorTrigger');
}