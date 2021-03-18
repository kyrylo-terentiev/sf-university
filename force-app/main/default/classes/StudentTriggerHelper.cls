public with sharing class StudentTriggerHelper {
    
    public static void setStudentName(List<Student__c> newList) {
        Map<Id, Student__c> accToStudMap = new Map<Id, Student__c>();
        for (Student__c stud : newList) {
            accToStudMap.put(stud.Account__c, stud);
        }
        Map<Id, Account> accMap = new Map<Id, Account>([
            SELECT Name
            FROM Account
            WHERE Id IN :accToStudMap.keySet()
        ]);
        for (Id accId : accToStudMap.keySet()) {
            accToStudMap.get(accId).Name = accMap.get(accId).Name;
        }
    }

    public static void validateStudentId(List<Student__c> newList) {
        for (Student__c stud : newList) {
            if (!Utils.validateStudentId(stud.StudentID__c)) {
                stud.StudentID__c.addError(System.Label.InvalidStudentID);
            }
        }
    }
}
