package com.example.ledger;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.math.RoundingMode;

import static org.junit.jupiter.api.Assertions.*;

class MoneyTest {

    @Test
    void doubleShowsFloatingPointPrecisionProblem() {
        double result = 0.1 + 0.2;

        System.out.println("double result: " + result);

        assertNotEquals(0.3, result);
    }

    @Test
    void bigDecimalFromStringsCalculatesExactly() {
        BigDecimal result = new BigDecimal("0.1")
                .add(new BigDecimal("0.2"));

        System.out.println("BigDecimal result: " + result);

        assertEquals(new BigDecimal("0.3"), result);
    }

    @Test
    void bigDecimalFromDoubleIsNotExact() {
        BigDecimal fromDouble = new BigDecimal(0.1);
        BigDecimal fromString = new BigDecimal("0.1");

        System.out.println("From double: " + fromDouble);
        System.out.println("From String: " + fromString);

        assertNotEquals(fromString, fromDouble);
    }

    @Test
    void equalsAndCompareToBehaveDifferently() {
        BigDecimal first = new BigDecimal("2.0");
        BigDecimal second = new BigDecimal("2.00");

        assertNotEquals(first, second);
        assertEquals(0, first.compareTo(second));
    }

    @Test
    void halfEvenRoundingWorksCorrectly() {
        BigDecimal amount = new BigDecimal("2.345");

        BigDecimal rounded = amount.setScale(
                2,
                RoundingMode.HALF_EVEN
        );

        System.out.println("Rounded amount: " + rounded);

        assertEquals(new BigDecimal("2.34"), rounded);
    }
}

