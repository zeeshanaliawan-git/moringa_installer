package com.etn.pages;

import java.io.*;

public class Command {

    public int exitValue;
    public StringBuilder standardOutput;
    public StringBuilder errorOutput;

    public Command() {
        exitValue = -1;
        standardOutput = new StringBuilder();
        errorOutput = new StringBuilder();
    }

    public void setException(Exception e) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        e.printStackTrace(pw);
        errorOutput.append(sw.toString());
    }

    public String getOutput() {
        return errorOutput.toString() + standardOutput.toString();
    }

    public static Command exec(String cmd, String[] envp, File dir) {
        Command command = new Command();
        Process p;
        try {
            p = Runtime.getRuntime().exec(cmd, envp, dir);
            BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));

            BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));
            // Read the output from the command
            String s = null;
            while ((s = stdInput.readLine()) != null) {
                command.standardOutput.append(s).append("\n");
            }
            while ((s = stdError.readLine()) != null) {
                command.errorOutput.append(s).append("\n");
            }
            p.waitFor();
            command.exitValue = p.exitValue();
            p.destroy();
        }
        catch (Exception e) {
            command.setException(e);
        }
        return command;
    }

    public static Command exec(String cmd) {
        return exec(cmd, null, null);
    }
}
