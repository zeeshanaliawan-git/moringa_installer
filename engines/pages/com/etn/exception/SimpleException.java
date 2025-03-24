package com.etn.exception;

/**
 * @author Ali Adnan
 * <p>
 * Just a wrapper Exception class to identify that it was thrown manually
 * to show custom error message before exiting
 */
public class SimpleException extends Throwable {

    Throwable ex = null;

    public SimpleException(String message) {
        super(message);
    }

    public SimpleException(String message, Throwable ex) {
        super(message);
        this.ex = ex;
    }

    public void print() {
        System.out.println(this.getMessage());
        if (ex != null) {
            ex.printStackTrace();
        }
    }

}
