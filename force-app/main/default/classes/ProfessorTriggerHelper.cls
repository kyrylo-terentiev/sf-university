public with sharing class ProfessorTriggerHelper {
    
    public static void setProfessorName(List<Professor__c> newList) {
        Map<Id, Professor__c> employeeToProfessorMap = new Map<Id, Professor__c>();
        for (Professor__c prof : newList) {
            employeeToProfessorMap.put(prof.Employee__c, prof);
        }
        Map<Id, Employee__c> employeeMap = new Map<Id, Employee__c>([
            SELECT Name
            FROM Employee__c
            WHERE Id IN :employeeToProfessorMap.keySet()
        ]);
        for (Id employeeId : employeeToProfessorMap.keySet()) {
            employeeToProfessorMap.get(employeeId).Name = employeeMap.get(employeeId).Name;
        }
    }

    public static void validateEmployee(List<Professor__c> newList, Boolean isUpdate) {
        Map<Id, Id> employeeToProfessorMap = new Map<Id, Id>();
        for (Professor__c prof : newList) {
            employeeToProfessorMap.put(prof.Employee__c, null);
        }
        Map<Id, Employee__c> employeeMap = new Map<Id, Employee__c>([
            SELECT Id, 
            (SELECT Id FROM Professors__r)
            FROM Employee__c
            WHERE Id IN :employeeToProfessorMap.keySet()
        ]);
        for (Id employeeId : employeeToProfessorMap.keySet()) {
            Employee__c empl = employeeMap.get(employeeId);
            Boolean isProfessor = empl != null && empl.Professors__r != null && !empl.Professors__r.isEmpty();
            if (isProfessor) {
                employeeToProfessorMap.put(employeeId, empl.Professors__r[0].Id);
            }
        }
        for (Professor__c prof : newList) {
            Id existingProfId = employeeToProfessorMap.get(prof.Employee__c);
            if (existingProfId != null) {
                if (!isUpdate || existingProfId != prof.Id) {
                    prof.addError('Professor record already exists for this employee');
                }
            }
        }
    }
}
