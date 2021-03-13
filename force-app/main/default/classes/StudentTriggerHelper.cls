public with sharing class StudentTriggerHelper {
    
    public static void setStudentName(List<Student__c> studentList) {
        for (Student__c stud : studentList) {
            stud.Name = Utils.getPersonRecordName(stud.LastName__c, stud.FirstName__c, stud.MiddleName__c);
        }
    }

    public static void validateStudentId(List<Student__c> studentList) {
        Pattern p;
        Matcher m;
        for (Student__C stud : studentList) {
            p = Pattern.compile('^([А-ЯA-Z]{2})([0-9]{8})');
            m = p.matcher(stud.StudentID__c);
            if (!m.matches()) {
                stud.StudentID__c.addError('Must match the following pattern: AA00000000');
            }
        }
    }
}
