package com.qa;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Runs every feature in parallel and fails the build if any scenario fails.
 *
 * Filter with Karate's standard option, e.g.:
 *   mvn test -Dkarate.options="--tags @smoke"
 *   mvn test -Dkarate.options="--tags @mock"           (offline)
 *   mvn test -Dkarate.options="--tags ~@mock"          (live API only)
 *   mvn test -Dkarate.options="classpath:features/carts"
 */
class ApiTestRunner {

    @Test
    void runAll() {
        Results results = Runner.path("classpath:features")
                .tags("~@ignore")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .parallel(4);
        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
