<%@ page import="java.lang.StringBuffer" %>

<%!
    public final String BLUE = "#0101FD";
    public final String ORANGE = "#FF6600";

    /** for semfree engine. */
    public final String SEMAPHORE = com.etn.beans.app.GlobalParm.getParm("SEMAPHORE");

    /** For CSV daily report. */
    public final char TYPE_DAILY = 'D';

    /** For CSV general report. */
    public final char TYPE_GENERAL = 'G';

    /** For CSV terminal delivery report. */
    public final char TYPE_TERMINAL_DELIVERY = 'T';

    /** For CSV portability cancellation request report. */
    public final char TYPE_PORTABILITY_CANCELLATION = 'P';

    /** Column name for reports. */
    public final String REPORTS_COLUMN_NAME = "record";

    /** Role user "plataforma", agente. */
    public final String ROLE_AGENT = "agente";

    /** Role user "coordinador", agente. */
    public final String ROLE_COORD = "coordinador";

    /** Role user "admin". */
    public final String ROLE_ADMIN = "admin2";

    // Estado Guizmo
    public final String NUEVA_SOLICITUD_SIM = "NuevaSolicitudSim62";
    public final String CANCELADO_A_POSTERIORI = "CanceladoAPosteriori42";
//    public final String CANCELADO_CLIENTE = "Cancelacion";
    public final String FALTAN_DATOS = "FaltanDatos45";
    public final String DATA_CHECK = "DataCheck";
    //public final String PENDIENTE_ESTUDIO = "Pendiente estudio";
    //public final String PENDIENTE_SCORING = "Pendiente Scoring";
    //public final String PENDIENTE_ACTIVACION = "Pendiente Activacion";
    //public final String RECHAZADO_SCORING = "Rechazado Scoring";
    //public final String NO_TRAMITABLE = "No tramitable";

    //public final String SOLICITUD_CANCELACION_PORTA = "Solicitud Cancelacion Porta";
    //public final String CLIENTE_EXISTENTE = "Cliente Existente";
    //public final String INCIDENCIA_DATOS = "Incidencia datos";
    //public final String VENTANA_CONFIRMADA = "Ventana confirmada";
    //public final String INCIDENCIA_DATOS_PORTA = "Incidencia Datos Porta";
    //public final String ACTIVADO_GUIZMO = "Activado guizmo";
    //public final String ACTIVADO_PLATAFORMA = "Activado Plataforma";
    //public final String ACTIVACION_NO_TRAMITABLE = "Activacion no tramitable";
    //public final String INCIDENCIA_ACTIVACION = "Incidencia activacion";

    public final String ALTA_PROCES_LABEL = "ALTA";
    public final String PORTA_PROCES_LABEL = "PORTA";
    public final String PORTA_PROCES_PREFIX = "portabilidad";

    //public final String EN_CURSO = "En curso";
    //public final String APROBADO_SCORING = "Aprobado Scoring";
    //public final String STATUS_PROCESANDO = "PROCESANDO";
    //public final String STATUS_DATOS_COMPLETADOS = "DATOS COMPLETADOS";
    //public final String ENTREGA_TERMINAL = "ENTREGA TERMINAL";
    //public final String SIM_INCLUIDA = "SIM INCLUIDA";
    //public final String STATUS_DATOS_INCLUIDOS = "DATOS INCLUIDOS";
    //public final String STATUS_DATOS_PORTA_COMPLETADOS = "DATOS PORTA COMPLETADOS";
    //public final String STATUS_SOLICITUD_CANCELACION_PORTA = "SOLICITUD CANCELACION PORTA";

    public final String ALTA_NUEVA_PREFIX = "alta nueva contrato";
    public final String ALTA_NUEVA_VALOR_PREFIX = "alta nueva contrato valor";
    public final String ALTA_NUEVA_PREMIUM_PREFIX = "alta nueva premium";

    public final String PORTA_PREFIX = "portabilidad";
    public final String PORTA_CONTRATO = "portabilidad contrato";
    public final String PORTA_VALOR = "portabilidad valor";
    public final String PORTA_CONTRATO_VALOR = "portabilidad contrato valor";
    public final String PORTA_PREMIUM = "portabilidad premium";

    //public final String ERROR_PROVINCIA = "130";
    //public final String ERROR_TIPO_VIA = "131";
    //public final String ERROR_NACIONALIDAD = "116";
    //public final String ERROR_IDENTIDAD_NIF = "122";
    //public final String ERROR_IDENTIDAD_TJT = "122";
    //public final String ERROR_NUM_TELEFONO = "132";
    //public final String ERROR_EMAIL = "133";
    //public final String ERROR_FECHA_NACIMIENTO = "36";
    //public final String ERROR_NOMBRE_SEXO = "134";
    //public final String ERROR_CUENTA_CORRIENTE = "35";
    //public final String ERROR_TARIF = "88";
    //public final String ERROR_TERMINAL = "89";
    //public final String ERROR_CONTRATO_MI_TIEMPO_LIBRE = "104";

    //public final String TARIFF_ARDILLA9 = "Ardilla 9";
    //public final int TIMETABLE_LENGTH_FOR_ARDILLA9 = 5;

    public final String SIN_MOTIVO = "SIN_MOTIVO";

    /*public final String OPERADOR_CHECKER = "GOCE";	// Guizmo Order Checker -> mark Error
    public final Object EXTRACTION = "Extraction";
    public final Object CONNECTOR_DOWN = "Down";
    public final Object INJECTION = "Injection";
    public final Object CONNECTOR_UP = "Up";

    public final String SERVICE_BLOCKED = "Bloqueado";
    public final String SERVICE_ENABLED = "Habilitado";
    
*/
%>

<%!  
    String parseNull(Object o)
	{
		if( o == null ) return("");
		String s = o.toString();
		if("null".equals(s.trim().toLowerCase())) return("");
		else return(s.trim());
	}

        
        int parseNullInt(Object o)
        {
            String s = parseNull(o);
            if(s.length() > 0 ){
                try{
                    return Integer.parseInt(s);
                }
                catch(Exception e){
                    return 0;
                }
            }
            else{
                return 0;
            }
        }

        
        double parseNullDouble(Object o)
        {
            String s = parseNull(o);
            if(s.length() > 0 ){
                try{
                    return Double.parseDouble(s);
                }
                catch(Exception e){
                    return 0;
                }
            }
            else{
                return 0;
            }
        }

    int ACCOUNT_NUMBER_LENGTH = 23;
    char ACCOUNT_NUMBER_SEPARATOR = '-';
    boolean checkAccountNumber(String accountNumber)
    {
        boolean res = true;

        // Parse account number format
        // Check on accountNumberCheck: length = 23
        if (accountNumber.length() == ACCOUNT_NUMBER_LENGTH)
        {
            StringBuffer bankBranchDigits = new StringBuffer(10);	// Buffer for bank and branch digits
            StringBuffer keyDigits = new StringBuffer(2);			// Buffer for key digits
            StringBuffer accountDigits = new StringBuffer(10);		// Buffer for account digits
            int i;													// Counter for loops

            // Loop to check account number format
            for (i = 0; i < accountNumber.length(); i++)
            {
                if (i < 4)
                {
                    if (Character.isDigit(accountNumber.charAt(i))) bankBranchDigits.append(accountNumber.charAt(i));
                    else res = false;
                }
                else if (i == 4 && res)
                {
                    if (accountNumber.charAt(4) != ACCOUNT_NUMBER_SEPARATOR) res = false;
                }
                else if (i < 9 && res)
                {
                    if (Character.isDigit(accountNumber.charAt(i))) bankBranchDigits.append(accountNumber.charAt(i));
                    else res = false;
                }
                else if (i == 9 && res)
                {
                    if (accountNumber.charAt(9) != ACCOUNT_NUMBER_SEPARATOR) res = false;
                }
                else if (i < 12 && res)
                {
                    if (Character.isDigit(accountNumber.charAt(i))) keyDigits.append(accountNumber.charAt(i));
                    else res = false;
                }
                else if (i == 12 && res)
                {
                    if (accountNumber.charAt(12) != ACCOUNT_NUMBER_SEPARATOR) res = false;
                }
                else if (i < ACCOUNT_NUMBER_LENGTH && res)
                {
                    if (Character.isDigit(accountNumber.charAt(i))) accountDigits.append(accountNumber.charAt(i));
                    else res = false;
                }
            }//end for

            // Check on key digits
            if (res && !mod11(bankBranchDigits, keyDigits.charAt(0))) res = false;
            if (res && !mod11(accountDigits, keyDigits.charAt(1))) res = false;
        }
        else res = false;
        return res;
    }
    int[] MUL = {1,2,4,8,5,10,9,7,3,6};
    boolean mod11(StringBuffer digits, char charKey)
    {
        int sum = 0;
        int offset;
        int digitsLength = digits.length();

        // Offset for calculation depends on string's length
        if (digitsLength == 8)		offset = 2;
        else 	offset = 0;

        for (int i = 0; i < digits.length(); i++)
            sum += MUL[i+offset] * Integer.parseInt(String.valueOf(digits.charAt(i)));

        int rest = sum % 11;

        switch (rest)
        {
            case 0:
            case 1:
                return (rest == Integer.parseInt(String.valueOf(charKey)));
            default:
                return ((11 - rest) == Integer.parseInt(String.valueOf(charKey)));
        }
    }
    //commenting this code as its used by massive status change logic in ibo.jsp which we dont need at the moment
    /*
    public boolean checkCustomerIdentityCard(String identityType, String identityId)
    {
        boolean res = false;

        if (identityType.equalsIgnoreCase("ppt")) res = true;
        else
        {	// Validation if document is not passport

            final String controlChars = "TRWAGMYFPDXBNJZSQVHLCKE";
            final String controlChars2 = "ABCDEFGHKLMNPQSXY";

            int identityLength = identityId.length();

            // Parse identityId format
            switch (identityLength)
            {
                // Admit short NIFs received from Ideup
                case 2:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                case 8:
                    // If NIF, pad with zeroes to get appropriate format and do normal validation
                    if (identityType.equalsIgnoreCase("nif"))
                    {
                        StringBuffer completedIdentityIdSb = new StringBuffer(9);
                        for (int i = 0; i < (9-identityLength); i++)
                        completedIdentityIdSb.append('0');
                        completedIdentityIdSb.append(identityId);
                        identityId = completedIdentityIdSb.toString();
                    }
                    else
                    {
                        break;	// If not NIF, it's bad format, so isIdentityCardOk stays false
                    }
                case 9:
                    char firstChar = identityId.charAt(0);
                    char lastChar = identityId.charAt(8);
                    char expected;

                    if (!controlChars2.contains(String.valueOf(firstChar)))
                    {
                    // DNI: 8 digits + char control
                        expected = controlChars.charAt(Integer.parseInt(identityId.substring(0, identityId.length()-1))%ACCOUNT_NUMBER_LENGTH);
                        if (expected == lastChar)	res = true;
                    }
                    else if (firstChar == 'X')
                    {
                        // NIE
                        expected = controlChars.charAt(Integer.parseInt(identityId.substring(1, identityId.length()-1))%ACCOUNT_NUMBER_LENGTH);
                        if (expected == lastChar)	res = true;
                    }
                    else if (firstChar == 'Y')
                    {
                        // NIE starting by Y
                        identityId = identityId.replace('Y', '1');
                        expected = controlChars.charAt(Integer.parseInt(identityId.substring(0, identityId.length()-1))%ACCOUNT_NUMBER_LENGTH);
                        if (expected == lastChar)	res = true;
                    } 
                    break;
                default:	// res = false; // ALREADY FALSE
            }
        }
        return res;
    }

	void markErrorForOrder(com.etn.beans.Contexte etn, String orderId, String custId, String errorType)
    {
        Set rsStatus = etn.execute("SELECT DISTINCT p.id, p.proces, p.phase, p.priority, p.attempt, p.errMessage, p.errCode, p.insertion_date,"
                        + " p.operador,p.client_key,p.flag,p.nextid,"
                        + " o.orderId, o.creationDate, o.orderStatus, o.orderType, c.identityId, c.identityType, c.terminal "
                        + " FROM post_work p, orders o, customer c"
                        + " WHERE p.client_key = o.orderId"
                        + " AND o.customerId = c.id"
                        + " AND p.status='0'"
                        + " AND p.client_key='"
			+ com.etn.sql.escape.cote(orderId)
			+ "' GROUP BY(client_key)");

        if (rsStatus.rs.Rows == 0)
        {
            System.out.println("ERROR: CURRENT STATUS WAS NOT FOUND FOR ORDER " + orderId +
            ". Probably there is no line in post_work having status = '0' for this order.");
            System.out.println("---> Impossible to update status (tables post_work and client) for order " + orderId);
        }
        else
        {
            rsStatus.next();
            String nextPhase = "Incidencia datos";
            Set rsPhase = etn.execute("SELECT next_phase FROM rules WHERE start_phase = "+com.etn.sql.escape.cote(rsStatus.value("phase"))+" AND errCode = "+ com.etn.sql.escape.cote(errorType));
            if(rsPhase.next()) nextPhase = rsPhase.value("next_phase");

            int nextId = etn.executeCmd("insert ignore into post_work (proces, phase, priority, insertion_date, client_key, operador, errCode, errMessage) SELECT "+com.etn.sql.escape.cote(rsStatus.value("proces"))+","+com.etn.sql.escape.cote(nextPhase)+",now(), now(),"+com.etn.sql.escape.cote(rsStatus.value("client_key"))+",'GOCE',"+com.etn.sql.escape.cote(rsStatus.value("errCode"))+", e.errmessage from errcode e where e.id = " + com.etn.sql.escape.cote(rsStatus.value("errCode")));

            if (nextId <= 0)
            {
                System.out.println("Error when inserting new status line!!!!");
            }
            else
            {
                etn.executeCmd("update post_work p, errcode e set p.status = '2', p.nextId = '"+nextId+"', p.errCode = '"+errorType+"', p.errMessage = e.errmessage, p.end = now() where p.id = "+com.etn.sql.escape.cote(rsStatus.value("id"))+" AND e.id = "+com.etn.sql.escape.cote(rsStatus.value("errCode")));
                etn.executeCmd("UPDATE customer SET lastid = "+com.etn.sql.escape.cote(rsStatus.value("id"))+" WHERE id = "+com.etn.sql.escape.cote(custId));
            }
        }
    }

    void checkState(com.etn.beans.Contexte etn, String orderId, String custId, String state)
    {
        Set rs = etn.execute("SELECT * FROM provincia WHERE name = "+com.etn.sql.escape.cote(state));
        if (rs.rs.Rows == 0)
        {
            markErrorForOrder(etn, orderId, custId, ERROR_PROVINCIA);
        }
    }

    void checkRouteType(com.etn.beans.Contexte etn, String orderId, String custId, String roadType)
    {
        Set rs = etn.execute("SELECT * FROM tipovia WHERE custin = "+com.etn.sql.escape.cote(roadType));
        if (rs.rs.Rows == 0)
        {
            markErrorForOrder(etn, orderId, custId, ERROR_TIPO_VIA);
        }
    }

    void checkCustomerNationality(com.etn.beans.Contexte etn, String orderId, String custId, String nationality)
    {
        Set rs = etn.execute("SELECT * FROM natio WHERE name = "+com.etn.sql.escape.cote(nationality));
        if (rs.rs.Rows == 0)
        {
            markErrorForOrder(etn, orderId, custId, ERROR_NACIONALIDAD);
        }
    }

    void checkCustomerIdentityCard(com.etn.beans.Contexte etn, String orderId, String custId, String identityType, String identityId)
    {
        boolean isIdentityCardOk = checkCustomerIdentityCard(identityType, identityId);
        if(!isIdentityCardOk)
        {
            if(identityType.equalsIgnoreCase("nif")) markErrorForOrder(etn, orderId, custId, ERROR_IDENTIDAD_NIF);
            else markErrorForOrder(etn, orderId, custId, ERROR_IDENTIDAD_TJT);
        }
    }

    void checkTelephoneNumber(com.etn.beans.Contexte etn, String orderId, String custId, String contactNumber1, String msisdn)
    {
        boolean isTelephoneNumberOk = true;
        if (contactNumber1.length() != 9)
            isTelephoneNumberOk = false;
        else if (msisdn.length() != 9 && msisdn.length() != 0)
            isTelephoneNumberOk = false;
        else
        {
            try
            {
                Integer.parseInt(contactNumber1);
                if (msisdn != null && msisdn.trim() != "")
                Integer.parseInt(msisdn);
            }
            catch (Exception e)
            {
                isTelephoneNumberOk = false;
            }
        }
        if (!isTelephoneNumberOk)
        {
            markErrorForOrder(etn, orderId, custId, ERROR_NUM_TELEFONO);
        }
    }

    void checkDateOfBirth(com.etn.beans.Contexte etn, String orderId, String custId, String dob)
    {
        boolean isDateOfBirthOk = true;

        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        sdf.setLenient(false);

        try
        {
            Date dateOfBirth = sdf.parse(dob);
            if (!sdf.format(dateOfBirth).equals(dob))
            isDateOfBirthOk = false;
        }
        catch (Exception e)
        {
            isDateOfBirthOk = false;
        }
        if (!isDateOfBirthOk)
        {
            markErrorForOrder(etn, orderId, custId, ERROR_FECHA_NACIMIENTO);
        }
    }

    void checkNameSurnamesSex(com.etn.beans.Contexte etn, String orderId, String custId, String custName, String custSurname, String gender)
    {
        boolean isDataOk = true;

        if (custName == null || custName.equals("")) isDataOk = false;
        else if (custSurname == null || custSurname.equals("")) isDataOk = false;
        else if (gender == null) isDataOk = false;
        else if (!gender.matches("^[MmHh]")) isDataOk = false;

        if (!isDataOk)
        {
            markErrorForOrder(etn, orderId, custId, ERROR_NOMBRE_SEXO);
        }
    }

    void checkAccountNumber(com.etn.beans.Contexte etn, String orderId, String custId, String accountNumber)
    {
        boolean isDataOk = checkAccountNumber(accountNumber);

        if (!isDataOk)
        {
            markErrorForOrder(etn, orderId, custId, ERROR_CUENTA_CORRIENTE);
        }
    }

    void checkTariff(com.etn.beans.Contexte etn, String orderId, String custId, String tarif, String tarifData)
    {
        Set rs = etn.execute("SELECT * FROM maptarif WHERE tarifVoiceIDEUP = "+com.etn.sql.escape.cote(tarif)+" AND tarifDataIDEUP = "+com.etn.sql.escape.cote(tarifData));

        if (rs.rs.Rows == 0)
        {
            markErrorForOrder(etn, orderId, custId, ERROR_TARIF);
        }
    }

    void checkContratoMiTiempoLibre(com.etn.beans.Contexte etn, String orderId, String custId, String tarif, String hDesde, String hHasta)
    {
        // Formerly called ContratoMiTiempoLibre, as of June 2010, it is Ardilla 9
        if (tarif.equals(TARIFF_ARDILLA9))
        {
            boolean isTerminalOk = (hDesde != null && hHasta != null && !hDesde.equals("") && !hHasta.equals(""));
            if(!isTerminalOk)
            {
                markErrorForOrder(etn, orderId, custId, ERROR_CONTRATO_MI_TIEMPO_LIBRE);
            }
        }
    }

    void checkTerminal(com.etn.beans.Contexte etn, String orderId, String custId, String terminal)
    {
        Set rs = etn.execute("SELECT * FROM mapterminal WHERE terminalIDEUP = "+com.etn.sql.escape.cote(terminal));
        if (rs.rs.Rows == 0)
        {
            markErrorForOrder(etn, orderId, custId, ERROR_TERMINAL);
        }
    }

    */
    boolean findFlagActif(com.etn.beans.Contexte etn, String order, String user)
    {
        etn.executeCmd("delete from flag where (TIMESTAMPDIFF(MINUTE, flagTime, now()) >= 10 )");
        Set rs = etn.execute("Select * from flag where orderID = "+com.etn.sql.escape.cote(order)+" AND operatorName != "+ com.etn.sql.escape.cote(user) +" And  (TIMESTAMPDIFF(MINUTE, flagTime, now()) <= 10)");
        if(rs.rs.Rows==0)
        {
            //return null;
            System.out.println("Order " + order + " is NOT locked in database for users different from " + user);
            return false;
        }
        else
        {
            System.out.println("Order " + order + " is LOCKED in database for users different from " + user);
            return true;
        }
    }



%>
