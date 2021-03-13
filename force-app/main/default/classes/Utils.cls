public class Utils {
    public static final Integer MAX_NAME_LENGTH = 80;
    
    public static String getPersonRecordName(String lastName, String firstName, String middleName) {
        String firstMiddleNameAbbr = firstName.substring(0, 1) + '.';
        Boolean hasMiddleName = !String.isEmpty(middleName);
        Integer maxLastNameLength;
        if (hasMiddleName) {
            maxLastNameLength = MAX_NAME_LENGTH - 5;
            firstMiddleNameAbbr += middleName.substring(0, 1) + '.';
        } else {
            maxLastNameLength = MAX_NAME_LENGTH - 3;
        }
        String lastNameAbbr = lastName.abbreviate(maxLastNameLength);
        return lastNameAbbr + ' ' + firstMiddleNameAbbr;
    }
}
