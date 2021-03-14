public with sharing class StudentTriggerHelper {
    
    public static void setStudentName(List<Student__c> newList) {
        for (Student__c stud : newList) {
            stud.Name = Utils.getPersonRecordName(
                stud.LastName__c, 
                stud.FirstName__c, 
                stud.MiddleName__c
            );
        }
    }

    public static void validateStudentId(List<Student__c> newList) {
        for (Student__c stud : newList) {
            if (!Utils.validateStudentId(stud.StudentID__c)) {
                stud.StudentID__c.addError('Must match the following pattern: AA00000000');
            }
        }
    }
}
