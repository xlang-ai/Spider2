## PR Overview
**This PR will address the following Issue/Feature:**

**This PR will result in the following new package version:**
<!--- Please add details around your decision for breaking vs non-breaking version upgrade. If this is a breaking change, were backwards-compatible options explored? -->

**Please detail what change(s) this PR introduces and any additional information that should be known during the review of this PR:**

## PR Checklist
### Basic Validation
Please acknowledge that you have successfully performed the following commands locally:
- [ ] dbt compile
- [ ] dbt run –full-refresh
- [ ] dbt run
- [ ] dbt test
- [ ] dbt run –vars (if applicable)

Before marking this PR as "ready for review" the following have been applied:
- [ ] The appropriate issue has been linked and tagged
- [ ] You are assigned to the corresponding issue and this PR
- [ ] BuildKite integration tests are passing

### Detailed Validation
Please acknowledge that the following validation checks have been performed prior to marking this PR as "ready for review":
- [ ] You have validated these changes and assure this PR will address the respective Issue/Feature.
- [ ] You are reasonably confident these changes will not impact any other components of this package or any dependent packages.
- [ ] You have provided details below around the validation steps performed to gain confidence in these changes.
<!--- Provide the steps you took to validate your changes below. -->

### Standard Updates
Please acknowledge that your PR contains the following standard updates:
- Package versioning has been appropriately indexed in the following locations:
    - [ ] indexed within dbt_project.yml
    - [ ] indexed within integration_tests/dbt_project.yml
- [ ] CHANGELOG has individual entries for each respective change in this PR
    <!--- If there is a parallel upstream change, remember to reference the corresponding CHANGELOG as an individual entry.  -->
- [ ] README updates have been applied (if applicable)
    <!--- Remember to check the following README locations for common updates. →
        <!--- Suggested install range (needed for breaking changes) →
        <!--- Dependency matrix is appropriately updated (if applicable) →
        <!--- New variable documentation (if applicable) -->
- [ ] DECISIONLOG updates have been updated (if applicable)
- [ ] Appropriate yml documentation has been added (if applicable)

### dbt Docs
Please acknowledge that after the above were all completed the below were applied to your branch:
- [ ] docs were regenerated (unless this PR does not include any code or yml updates)

### If you had to summarize this PR in an emoji, which would it be?
<!--- For a complete list of markdown compatible emojis check our this git repo (https://gist.github.com/rxaviers/7360908)  --> 
:dancer:
