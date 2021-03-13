public with sharing class StudentTriggerHelper {
    
    public static void setStudentName(List<Student__c> studentList) {
        for (Student__c stud : studentList) {
            stud.Name = Utils.getPersonRecordName(stud.LastName__c, stud.FirstName__c, stud.MiddleName__c);
        }
    }
}
