public class Utils {
    public static final Integer MAX_NAME_LENGTH = 80;
    
    public static Boolean validatePersonName(String lastName, String firstName, String middleName) {
        String regex = '^([а-яА-Яa-zA-Z])[а-яА-Яa-zA-Z- ]*([а-яА-Яa-zA-Z])$';
        Boolean matches = Pattern.compile(regex).matcher(lastName.trim()).matches()
                        && Pattern.compile(regex).matcher(firstName.trim()).matches()
                        && (!String.isEmpty(middleName) 
                        ? Pattern.compile(regex).matcher(middleName.trim()).matches() 
                        : true);
        return matches;
    }

    public static String getPersonRecordName(String lastName, String firstName, String middleName) {
        String firstMiddleNameAbbr = firstName.substring(0, 1).toUpperCase() + '. ';
        Boolean hasMiddleName = !String.isEmpty(middleName);
        Integer maxLastNameLength;
        if (hasMiddleName) {
            maxLastNameLength = MAX_NAME_LENGTH - 6;
            firstMiddleNameAbbr += middleName.substring(0, 1).toUpperCase() + '.';
        } else {
            maxLastNameLength = MAX_NAME_LENGTH - 3;
        }
        String lastNameAbbr = lastName.toLowerCase().capitalize().abbreviate(maxLastNameLength);
        return (lastNameAbbr + ' ' + firstMiddleNameAbbr).trim();
    }

    public static Boolean validateStudentId(String studentId) {
        String regex = '^([А-ЯA-Z]{2})([0-9]{8})';
        return Pattern.compile(regex).matcher(studentId.trim()).matches();
    }
}
