package com.dental.app.clinicadentalapp;

import org.junit.platform.suite.api.*;

import static io.cucumber.junit.platform.engine.Constants.GLUE_PROPERTY_NAME;

@Suite
@IncludeEngines("cucumber")
@SelectClasspathResource("features")
@IncludeTags({
        "CP-001",
        "CP-002",
        "CP-003",
        "CP-004",
        "CP-005",
        "CP-006",
        "CP-007",
        "CP-008",
        "CP-009",
        "CP-010",
        "CP-011",
        "CP-012",
        "CP-013",
        "CP-014",
        "CP-015",
        "CP-016",
        "CP-017",
        "CP-018",
        "CP-019",
        "CP-020"
})
@ConfigurationParameter(
        key = GLUE_PROPERTY_NAME,
        value = "com.dental.app.clinicadentalapp.stepdefinitions")
public class RunCucumberTest {

}