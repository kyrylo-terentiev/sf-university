trigger DepartmentCourseGroupLessonTrigger on DepartmentCourseGroupLesson__c (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
) {
    TriggerDispatcher.run(new DepartmentCourseGroupLessonTriggerHandlr(), 'LessonTrigger');
}