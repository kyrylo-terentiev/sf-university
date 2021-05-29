@isTest
public class TestObjectFactory {

    private static final String STUDENT_ID = 'AA00000000';

    public static Account createAccount() {
        return new Account(
            Name = 'TestName',
            FirstName__c = 'TestFirstName',
            LastName__c = 'TestLastName',
            MiddleName__c = 'TestMiddleName',
            Email__c = 'testing@test.com',
            DateOfBirth__c = Date.newInstance(1999, 1, 1),
            IsActive__c = true
        );
    }

    public static List<Account> createAccounts(Integer accountNum) {
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < accountNum; i++) {
            accList.add(createAccount());
        }
        return accList;
    }

    public static Professor__c createProfessor(Account acc) {
        return new Professor__c(
            Name = acc.Name,
            Account__c = acc.Id,
            Degree__c = 'Bachelor',
            Position__c = 'Professor',
            IsActive__c = true
        );
    }

    public static List<Professor__c> createProfessors(List<Account> accList) {
        List<Professor__c> professorList = new List<Professor__c>();
        for (Account acc : accList) {
            professorList.add(createProfessor(acc));
        }
        return professorList;
    }

    public static Student__c createStudent(Account acc) {
        return createStudent(acc, STUDENT_ID);
    }

    public static Student__c createStudent(Account acc, String studentId) {
        return new Student__c(
            Name = 'TestName',
            StudentID__c = studentId,
            Account__c = acc.Id,
            Degree__c = 'Bachelor',
            FormOfStudy__c = 'Full-Time',
            IsActive__c = true
        );
    }

    public static List<Student__c> createStudents(List<Account> accList) {
        List<Student__c> studentList = new List<Student__c>();
        for (Integer i = 0; i < accList.size(); i++) {
            studentList.add(createStudent(accList[i], STUDENT_ID.substring(0, STUDENT_ID.length() - String.valueOf(i).length()) + String.valueOf(i)));
        }
        return studentList;
    }

    public static StudentGroup__c createStudentGroup(Department__c dep) {
        return new StudentGroup__c(
            Name = 'TestStudentGroup',
            Department__c = dep.Id,
            IsActive__c = true
        );
    }

    public static List<StudentGroupMember__c> createStudentGroupMembers(StudentGroup__c studGroup, List<Student__c> studList) {
        List<StudentGroupMember__c> memberList = new List<StudentGroupMember__c>();
        for (Student__c stud : studList) {
            memberList.add(new StudentGroupMember__c(
                Group__c = studGroup.Id,
                Student__c = stud.Id,
                IsActive__c = true
            ));
        }
        return memberList;
    }

    public static Faculty__c createFaculty(Professor__c dean) {
        return new Faculty__c(
            Name = 'TestFaculty',
            FullName__c = 'TestFaculty',
            Dean__c = dean.Id,
            IsActive__c = true
        );
    }

    public static Course__c createCourse(Faculty__c fac) {
        return createCourse(fac, 'TC');
    }

    public static Course__c createCourse(Faculty__c fac, String shortName) {
        return new Course__c(
            Name = 'TestCourse',
            ShortName__c = shortName,
            Faculty__c = fac.Id,
            IsActive__c = true
        );
    }

    public static Department__c createDepartment(Faculty__c fac, Professor__c head) {
        return new Department__c(
            Name = 'TestDepartment',
            FullName__c = 'TestDepartment',
            Faculty__c = fac.Id,
            HeadOfDepartment__c = head.Id,
            IsActive__c = true
        );
    }

    public static DepartmentCourse__c createDepartmentCourse(Department__c dep, Course__c course) {
        return new DepartmentCourse__c(
            Department__c = dep.Id,
            Course__c = course.Id,
            IsActive__c = true
        );
    }

    public static DepartmentCourseGroup__c createDepartmentCourseGroup(Course__c course, StudentGroup__c studGroup) {
        return new DepartmentCourseGroup__c(
            Course__c = course.Id,
            StudentGroup__c = studGroup.Id,
            IsActive__c = true
        );
    }

    public static DepartmentProfessor__c createDepartmentProfessor(Department__c dep, Professor__c prof) {
        return new DepartmentProfessor__c(
            Department__c = dep.Id,
            Professor__c = prof.Id
        );
    }

    public static DepartmentCourseProfessor__c createDepartmentCourseProfessor(Department__c dep, Course__c course, Professor__c prof) {
        return new DepartmentCourseProfessor__c(
            Department__c = dep.Id,
            Course__c = course.Id,
            Professor__c = prof.Id,
            IsActive__c = true
        );
    }

    public static Lesson__c createLesson(Department__c dep, Course__c course, Professor__c prof) {
        return createLesson(dep, course, prof, Date.today(), 'Lecture', 'I', '08:00', '09:35');
    }

    public static DepartmentCourseGroupLesson__c createDepartmentCourseGroupLesson(Lesson__c lsn, StudentGroup__c studGroup) {
        return new DepartmentCourseGroupLesson__c(
            Lesson__c = lsn.Id,
            StudentGroup__c = studGroup.Id
        );
    }

    public static Lesson__c createLesson(Department__c dep, Course__c course, Professor__c prof, Date lessonDate, String type, String orderNumber, String startTime, String endTime) {
        return new Lesson__c(
            Department__c = dep.Id,
            Course__c = course.Id,
            Professor__c = prof.Id,
            Date__c = lessonDate,
            OrderNumber__c = orderNumber,
            StartTimePicklist__c = startTime,
            EndTimePicklist__c = endTime,
            Type__c = type,
            IsActive__c = true
        );
    }

    public static StudentLessonAttendance__c createStudentLessonAttendance(Student__c stud, StudentGroup__c studGroup, Lesson__c lsn) {
        return new StudentLessonAttendance__c(
            Student__c = stud.Id,
            StudentGroup__c = studGroup.Id,
            Lesson__c = lsn.Id
        );
    }

    public static Task__c createTask(Department__c dep, Course__c course, Lesson__c lsn) {
        return new Task__c(
            Name = 'TestTask',
            Department__c = dep.Id,
            Course__c = course.Id,
            Lesson__c = lsn.Id
        );
    }

    public static Task__c createTask(Department__c dep, Course__c course) {
        return new Task__c(
            Name = 'TestTask',
            Department__c = dep.Id,
            Course__c = course.Id
        );
    }

    public static TaskAssignment__c createTaskAssignment(Task__c tsk, Student__c stud, StudentGroup__c studGroup) {
        return new TaskAssignment__c(
            Task__c = tsk.Id,
            Student__c = stud.Id,
            StudentGroup__c = studGroup.Id
        );
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