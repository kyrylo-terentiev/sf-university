@isTest
public class TestObjectFactory {

    public static Account createAccount() {
        Account acc = new Account(
            Name = 'TestName',
            FirstName__c = 'TestFirstName',
            LastName__c = 'TestLastName',
            MiddleName__c = 'TestMiddleName',
            DateOfBirth__c = Date.newInstance(1999, 1, 1)
        );
        return acc;
    }

    public static List<Account> createAccounts(Integer accountNum) {
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < accountNum; i++) {
            accList.add(createAccount());
        }
        return accList;
    }

    public static Professor__c createProfessor(Account acc) {
        Professor__c prof = new Professor__c(
            Name = acc.Name,
            Account__c = acc.Id
        );
        return prof;
    }

    public static List<Professor__c> createProfessors(List<Account> accList) {
        List<Professor__c> professorList = new List<Professor__c>();
        for (Account acc : accList) {
            professorList.add(createProfessor(acc));
        }
        return professorList;
    }

    public static Student__c createStudent(Account acc, String studentId) {
        Student__c stud = new Student__c(
            Name = 'TestName',
            StudentID__c = studentId,
            Account__c = acc.Id
        );
        return stud;
    }

    public static List<Student__c> createStudents(List<Account> accList, String studentIdTemplate) {
        List<Student__c> studentList = new List<Student__c>();
        for (Integer i = 0; i < accList.size(); i++) {
            String ending = String.valueOf(i);
            String studentId = studentIdTemplate.substring(0, studentIdTemplate.length() - ending.length()) + ending;
            studentList.add(createStudent(accList[i], studentId));
        }
        return studentList;
    }
}