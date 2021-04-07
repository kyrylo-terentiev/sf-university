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

    public static Student__c createStudent(Account acc) {
        Student__c stud = new Student__c(
            Name = 'TestName',
            StudentID__c = 'AA00000000',
            Account__c = acc.Id,
            Degree__c = 'Bachelor',
            FormOfStudy__c = 'Full-Time',
            IsActive__c = true
        );
        return stud;
    }

    public static List<Student__c> createStudents(List<Account> accList) {
        String studentIdTemplate = 'AA00000000';
        List<Student__c> studentList = new List<Student__c>();
        for (Integer i = 0; i < accList.size(); i++) {
            String ending = String.valueOf(i);
            String studentId = studentIdTemplate.substring(0, studentIdTemplate.length() - ending.length()) + ending;
            Student__c stud = createStudent(accList[i]);
            stud.StudentID__c = studentId;
            studentList.add(stud);
        }
        return studentList;
    }

    public static StudentGroup__c createStudentGroup() {
        StudentGroup__c studGroup = new StudentGroup__c(
            Name = 'TestStudentGroup',
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
            Dean__c = dean.Id,
            IsActive__c = true
        );
        return fac;
    }

    public static Course__c createCourse(Faculty__c fac) {
        Course__c course = new Course__c(
            Name = 'TestCourse',
            Faculty__c = fac.Id,
            IsActive__c = true
        );
        return course;
    }

    public static Department__c createDepartment(Faculty__c fac, Professor__c head) {
        Department__c dep = new Department__c(
            Name = 'TestDepartment',
            Faculty__c = fac.Id,
            HeadOfDepartment__c = head.Id,
            IsActive__c = true
        );
        return dep;
    }

    public static DepartmentCourse__c createDepartmentCourse(Department__c dep, Course__c course) {
        DepartmentCourse__c depCourse = new DepartmentCourse__c(
            Name = 'TestDepartmentCourse',
            Department__c = dep.Id,
            Course__c = course.Id,
            IsActive__c = true
        );
        return depCourse;
    }

    public static DepartmentCourseGroup__c createDepartmentCourseGroup(DepartmentCourse__c depCourse, StudentGroup__c studGroup) {
        DepartmentCourseGroup__c depCourseGroup = new DepartmentCourseGroup__c(
            DepartmentCourse__c = depCourse.Id,
            StudentGroup__c = studGroup.Id,
            IsActive__c = true
        );
        return depCourseGroup;
    }

    public static DepartmentProfessor__c createDepartmentProfessor(Department__c dep, Professor__c prof) {
        DepartmentProfessor__c depProf = new DepartmentProfessor__c(
            Name = 'TestDepartmentProfessor',
            Department__c = dep.Id,
            Professor__c = prof.Id
        );
        return depProf;
    }

    public static DepartmentCourseProfessor__c createDepartmentCourseProfessor(DepartmentCourse__c depCourse, DepartmentProfessor__c depProf) {
        DepartmentCourseProfessor__c depCourseProf = new DepartmentCourseProfessor__c(
            Department__c = depCourse.Department__c,
            DepartmentCourse__c = depCourse.Id,
            DepartmentProfessor__c = depProf.Id,
            IsActive__c = true
        );
        return depCourseProf;
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
                , IsActive__c
            FROM Account
        ];
    }
}