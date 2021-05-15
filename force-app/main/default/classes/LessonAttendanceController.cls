public with sharing class LessonAttendanceController {
     
    @AuraEnabled(cacheable=true)
    public static List<StudentLessonAttendance__c> getAttendances(Id lessonId) {
        return [
            SELECT Id
                , Student__c
                , Student__r.Name
                , StudentGroup__c
                , StudentGroup__r.Name
                , IsAttending__c
            FROM StudentLessonAttendance__c
            WHERE Lesson__c = :lessonId
                AND IsActive__c = TRUE
            ORDER BY StudentGroup__r.Name
        ];
    }

    @AuraEnabled
    public static void updateAttendances(String data) {
        List<StudentLessonAttendance__c> attendances = (List<StudentLessonAttendance__c>) JSON.deserialize(data, List<StudentLessonAttendance__c>.class);
        try {
            update attendances;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}