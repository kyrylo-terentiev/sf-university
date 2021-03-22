@isTest
public class TestObjectFactory {

    public static Account createAccount() {
        Account acc = new Account(
            Name = 'TestName',
            FirstName__c = 'TestFirstName',
            LastName__c = 'TestLastName',
            MiddleName__c = 'TestMiddleName',
            DateOfBirth__c = Date.newInstance(1999, 1, 1),
            IsActive__c = true
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
            Account__c = acc.Id,
            Degree__c = 'Bachelor',
            Position__c = 'Professor',
            IsActive__c = true
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
            Account__c = acc.Id,
            Degree__c = 'Bachelor',
            FormOfStudy__c = 'Full-Time',
            IsActive__c = true
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

    public static StudentGroup__c createStudentGroup(Student__c head) {
        StudentGroup__c studGroup = new StudentGroup__c(
            Name = 'TestStudentGroup',
            HeadOfGroup__c = head.Id,
            IsActive__c = true
        );
        return studGroup;
    }

    public static List<StudentGroupMember__c> createStudentGroupMembers(StudentGroup__c studGroup, List<Student__c> studList) {
        List<StudentGroupMember__c> memberList = new List<StudentGroupMember__c>();
        for (Student__c stud : studList) {
            StudentGroupMember__c member = new StudentGroupMember__c(
                Group__c = studGroup.Id,
                Student__c = stud.Id,
                IsActive__c = true
            );
            memberList.add(member);
        }
        return memberList;
    }

    public static Faculty__c createFaculty(Professor__c dean) {
        Faculty__c fac = new Faculty__c(
            Name = 'TestFaculty',
            Dean__c = dean.Id
        );
        return fac;
    }

    public static Department__c createDepartment(Faculty__c fac, Professor__c head) {
        Department__c dep = new Department__c(
            Name = 'TestDepartment',
            Faculty__c = fac.Id,
            HeadOfDepartment__c = head.Id
        );
        return dep;
    }

    public static List<Account> getTestAccounts() {
        return [
            SELECT Id
                , Name
                , FirstName__c
                , LastName__c
                , MiddleName__c
                , DateOfBirth__c
                , FullName__c
                , User__c
            FROM Account
        ];
    }
}