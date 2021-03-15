public with sharing class EmployeeTriggerHelper {
    
    public static void validateEmployeeName(List<Employee__c> newList) {
        for (Employee__c empl : newList) {
            if (!Utils.validatePersonName(empl.LastName__c, empl.FirstName__c, empl.MiddleName__c)) {
                empl.addError('Name fields should contain only alphabetic characters, hyphens and spaces');
            }
        }
    }

    public static void setEmployeeName(List<Employee__c> newList) {
        for (Employee__c empl : newList) {
            empl.Name = Utils.getPersonRecordName(empl.LastName__c, empl.FirstName__c, empl.MiddleName__c);
        }
    }

    public static void updateChildren(Map<Id, Employee__c> newMap, Map<Id, Employee__c> oldMap) {
        List<Professor__c> professorsToUpdate = new List<Professor__c>();
        Map<Id, List<Professor__c>> employeeToProfessorsMap = new Map<Id, List<Professor__c>>();
        for (Professor__c prof : [SELECT Name, Employee__c FROM Professor__c WHERE Employee__c IN :newMap.keySet()]) {
            if (employeeToProfessorsMap.get(prof.Employee__c) == null) {
                employeeToProfessorsMap.put(prof.Employee__c, new List<Professor__c>());
            }
            employeeToProfessorsMap.get(prof.Employee__c).add(prof);
        }
        for (Id employeeId : employeeToProfessorsMap.keySet()) {
            Employee__c newEmpl = newMap.get(employeeId);
            Employee__c oldEmpl = oldMap.get(employeeId);
            List<Professor__c> professorList = employeeToProfessorsMap.get(employeeId);
            if (newEmpl.Name != oldEmpl.Name) {
                for (Professor__c prof : professorList) {
                    prof.Name = newEmpl.Name;
                    professorsToUpdate.add(prof);
                }
            }
        }
        System.debug('professorsToUpdate: ' + professorsToUpdate);
        if (!professorsToUpdate.isEmpty()) {
            update professorsToUpdate;
        }
    }
}
