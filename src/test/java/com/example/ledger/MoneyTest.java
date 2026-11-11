package com.example.ledger;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.math.RoundingMode;

import static org.junit.jupiter.api.Assertions.*;

class MoneyTest {

    @Test
    void doubleShowsFloatingPointPrecisionProblem() {
        double result = 0.1 + 0.2;

        BigDecimal actual = BigDecimal.valueOf(result);
        BigDecimal expected = new BigDecimal("0.3");

        assertNotEquals(0, actual.compareTo(expected));
    }

    @Test
    void bigDecimalFromStringsCalculatesExactly() {
        BigDecimal result = new BigDecimal("0.1")
                .add(new BigDecimal("0.2"));

        assertEquals(new BigDecimal("0.3"), result);
    }

    @Test
    void bigDecimalFromDoubleIsNotExact() {
        BigDecimal fromDouble = new BigDecimal(0.1);
        BigDecimal fromString = new BigDecimal("0.1");

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
        BigDecimal first = new BigDecimal("2.345");
        BigDecimal second = new BigDecimal("2.355");

        assertEquals(
                new BigDecimal("2.34"),
                first.setScale(2, RoundingMode.HALF_EVEN)
        );

        assertEquals(
                new BigDecimal("2.36"),
                second.setScale(2, RoundingMode.HALF_EVEN)
        );
    }

    @Test
    void halfUpRoundingWorksCorrectly() {
        BigDecimal amount = new BigDecimal("2.345");

        BigDecimal rounded = amount.setScale(
                2,
                RoundingMode.HALF_UP
        );

        assertEquals(new BigDecimal("2.35"), rounded);
    }
}

