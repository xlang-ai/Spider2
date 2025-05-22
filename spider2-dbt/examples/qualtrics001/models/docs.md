{% docs _fivetran_synced %}
The time when a record was last updated by Fivetran.
{% enddocs %}

{% docs source_relation %}
The schema or database this record came from if you are making use of the qualtrics_union_schemas or qualtrics_union_databases variables, respectively. Empty string if you are not using either of these variables to union together multiple Qualtrics connectors.
{% enddocs %}

{% docs _fivetran_deleted %}
Boolean representing whether the record was soft-deleted in Qualtrics.
{% enddocs %}

{% docs block_locking %}
Boolean representing whether modification of the block and its contents is prevented.
{% enddocs %}

{% docs block_visibility %}
Whether the questions in the block are 'collapsed' or 'expanded' by default.
{% enddocs %}

{% docs block_description %}
Description given to the block.
{% enddocs %}

{% docs block_id %}
The ID of the survey block. Match pattern = ^BL_[a-zA-Z0-9]{11,15}$
{% enddocs %}

{% docs randomize_questions %}
If/how the block questions are randomized. Can be - `false` (no randomization), `RandomWithXPerPage` (randomize all and place X questions in each block), `RandomWithOnlyX` (randomly present only X out of the total questions), or `Advanced` (custom configuration)
{% enddocs %}

{% docs survey_id %}
The unique identifier for this survey. Match pattern = ^SV_[a-zA-Z0-9]{11,15}$
{% enddocs %}

{% docs block_type %}
Type of block. Can be `Trash`, `Default`, or `Standard`
{% enddocs %}

{% docs user_id %}
Unique ID of the user. Match pattern  = ^((UR)|(URH))_[0-9a-zA-Z]{11,15}$ 
{% enddocs %}

{% docs division_id %}
The unique identifier for the Division ID. Match pattern = ^DV_[0-9a-zA-Z]{11,15}$
{% enddocs %}

{% docs username %}
UI-facing username for the account.
{% enddocs %}

{% docs user_first_name %}
The user's first name or given name.
{% enddocs %}

{% docs user_last_name %}
User's surname.
{% enddocs %}

{% docs user_type %}
ID of the user type. See mappings of user types to their type IDs [here](https://api.qualtrics.com/dc2be1c61af61-user-type).
{% enddocs %}

{% docs organization_id %}
ID of the organization/brand this record belongs to.
{% enddocs %}

{% docs language %}
The user's default language.
{% enddocs %}

{% docs unsubscribed %}
Boolean indicating if the user unsubscribed.
{% enddocs %}

{% docs account_creation_date %}
The date and time that the account was created. Dates and times are expressed in ISO 8601 format.
{% enddocs %}

{% docs account_expiration_date %}
The date the account expires. Dates and times are expressed in ISO 8601 format.
{% enddocs %}

{% docs account_status %}
Either `active`, `disabled`, or `notVerified`.
{% enddocs %}

{% docs email %}
The user's email address.
{% enddocs %}

{% docs last_login_date %}
The date and time the user last logged into the user interface. Dates and times are expressed in ISO 8601 format.
{% enddocs %}

{% docs password_expiration_date %}
The date the account password expires. Dates and times are expressed in ISO 8601 format.
{% enddocs %}

{% docs password_last_changed_date %}
The date the account password was last changed. Dates and times are expressed in ISO 8601 format.
{% enddocs %}

{% docs response_count_auditable %}
The count of auditable responses.
{% enddocs %}

{% docs response_count_deleted %}
The count of deleted responses.
{% enddocs %}

{% docs response_count_generated %}
The count of generated responses.
{% enddocs %}

{% docs time_zone %}
The IANA time zone setting for the user.
{% enddocs %}

{% docs auto_scoring_category %}
The automated scoring category.
{% enddocs %}

{% docs brand_base_url %}
Base url for the organization/brand.
{% enddocs %}

{% docs brand_id %}
Unique ID of the organization/brand.
{% enddocs %}

{% docs bundle_short_name %}
Short name for the content bundle that the survey is from.
{% enddocs %}

{% docs composition_type %}
Survey composition type.
{% enddocs %}

{% docs creator_id %}
The unique identifier for a specific `USER` who created the survey.
{% enddocs %}

{% docs default_scoring_category %}
The default scoring category.
{% enddocs %}

{% docs is_active %}
DEPRECATED. Use `survey_status = 'active'` instead.
{% enddocs %}

{% docs last_accessed %}
The date the survey was last accessed.
{% enddocs %}

{% docs last_activated %}
The date the survey was last activated.
{% enddocs %}

{% docs owner_id %}
The unique identifier for a specific user who owns this.
{% enddocs %}

{% docs project_category %}
Project category of the survey.

Allowed values - `CORE`, `CX`, `EX`, `BX`, `PX`
{% enddocs %}

{% docs project_type %}
Type of [Qualtrics project](https://www.qualtrics.com/support/survey-platform/my-projects/my-projects-overview/#SelectingProjectType). Match pattern = ^[a-zA-Z]+$
{% enddocs %}

{% docs registry_sha %}
The survey registry SHA.
{% enddocs %}

{% docs registry_version %}
The survey registry version.
{% enddocs %}

{% docs schema_version %}
Qualtrics schema version.
{% enddocs %}

{% docs scoring_summary_after_questions %}
Boolean representing whether the scoring summary is after questions.
{% enddocs %}

{% docs scoring_summary_after_survey %}
Boolean representing whether the scoring summary is after the survey.
{% enddocs %}

{% docs scoring_summary_category %}
The unique identifier for the scoring.
{% enddocs %}

{% docs survey_name %}
Name of the survey.
{% enddocs %}

{% docs survey_status %}
The distribution status of the survey, or a flag indicating that it's a library block

Allowed values - `Inactive`, `Active`, `Pending`, `LibBlock`, `Deactive`, `Temporary`
{% enddocs %}

{% docs data_export_tag %}
The tag to identify the question in exported data.
{% enddocs %}

{% docs choice_data_export_tag %}
The tag to identify the question choice in exported data.
{% enddocs %}

{% docs data_visibility_hidden %}
Boolean that represents whether the embedded data is hidden.
{% enddocs %}

{% docs data_visibility_private %}
Boolean that represents whether the embedded data is private.
{% enddocs %}

{% docs question_id %}
The unique identifier for the question. Match pattern = ^QID[a-zA-Z0-9]+$
{% enddocs %}

{% docs next_answer_id %}
For Matrix questions, the vertical options are denoted as "Answers" in the question's structure. 
ID of the next answer for this question. ? 
{% enddocs %}

{% docs next_choice_id %}
For Matrix questions, the horizontal options are denoted as "Choices" in the question's structure. 

ID of the next choice for this question. ? 
{% enddocs %}

{% docs question_description %}
Label to identify the question.
{% enddocs %}

{% docs question_description_option %}
An optional user-provided field for question descriptions. Accepted values = `UseText`, `SpecifyLabel`
{% enddocs %}

{% docs question_text %}
Text for the question.
{% enddocs %}

{% docs question_text_unsafe %}
Un-paresed version of the question text.
{% enddocs %}

{% docs question_type %}
The type of question. Can be -
`MC`,`Matrix`,`Captcha`,`CS`,`DB`,`DD`,`Draw`,`DynamicMatrix`,`FileUpload`,`GAP`,`HeatMap`,`HL`,`HotSpot`,`Meta`,`PGR`,`RO`,`SBS`,`Slider`,`SS`,`TE`,`Timing`,`TreeSelect`
{% enddocs %}

{% docs selector %}
How answers are selected such as single answer, multiple answer, etc. Accepted values - 
- `Bipolar`
- `Browser`
- `Captcha`
- `CompactView`
- `CS`
- `D`
- `DL`
- `DND`
- `DragAndDrop`
- `ESTB`
- `FORM`
- `FileUpload`
- `GRB`
- `HBAR`
- `HR`
- `HSLIDER`
- `I`
- `Image`
- `LikeDislike`
- `Likert`
- `MACOL`
- `MAHR`
- `MAVR`
- `ML`
- `MSB`
- `MaxDiff`
- `NPS`
- `OH`
- `OnOff`
- `POS`
- `PTB`
- `PW`
- `PageTimer`
- `Profile`
- `RB`
- `RO`
- `SACOL`
- `SAHR`
- `SAVR`
- `SB`
- `SBSMatrix`
- `SL`
- `STAR`
- `ScreenCapture`
- `SearchOnly`
- `Signature`
- `TA`
- `TB`
- `TBelow`
- `TE`
- `TL`
- `TRight`
- `Text`
- `V1`
- `V2`
- `VR`
- `VRTL`
- `WTXB`
{% enddocs %}

{% docs sub_selector %}
How subquestion answers are selected. Allowed values - SingleAnswer, DL, GR, DND, Long, Medium, MultipleAnswer, Columns, NoColumns, Short, TX, TXOT, WOTXB, WOTB, WTB, WTXB, WVTB.
{% enddocs %}

{% docs validation_setting_force_response %}
The response from forcing respondents to answer a question or request that they consider answering the question before leaving the page
{% enddocs %}

{% docs validation_setting_force_response_type %}
The type of response from forcing respondents to answer a question or request that they consider answering the question before leaving the page
{% enddocs %}

{% docs validation_setting_type %}
The type of forced response validation that is set.
{% enddocs %}

{% docs question_response_fivetran_id %}
Fivetran-generated unique key hashed on `response_id`, `question_id`, `sub_question_key`, `sub_question_text` , `question_option_key` , `loop_id` and `importId`.
{% enddocs%}

{% docs loop_id %}
ID of the [Loop and Merge](https://www.qualtrics.com/support/survey-platform/survey-module/block-options/loop-and-merge/) object this response is associated with.
{% enddocs %}

{% docs question %}
Question text.
{% enddocs %}

{% docs question_option_key %}
The key of the `QUESTION_OPTION` that was chosen.
{% enddocs %}

{% docs sub_question_option_key %}
The key of the `QUESTION_OPTION` that was chosen for the sub-question.
{% enddocs %}

{% docs sub_question_text %}
Sub question text.
{% enddocs %}

{% docs response_value %}
Value of the question response.
{% enddocs %}

{% docs recode_value %}
Recode/mapping value for the option.
{% enddocs %}

{% docs question_option_text %}
Question option text.
{% enddocs %}

{% docs distribution_channel %}
The method by which the survey was distributed to respondents.
{% enddocs %}

{% docs duration_in_seconds %}
How long it took for the respondent to finish the survey in seconds.
{% enddocs %}

{% docs end_date %}
The point in time when the survey response was finished.
{% enddocs %}

{% docs finished %}
Boolean (stored as int) indicating if the respondent finished and submitted the survey, the value will be 1, otherwise it will be 0.
{% enddocs %}

{% docs response_id %}
The unique ID for the `SURVEY_RESPONSE`.
{% enddocs %}

{% docs ip_address %}
IP address of the recipient.
{% enddocs %}

{% docs last_modified_date %}
The point in time when the record was last modified.
{% enddocs %}

{% docs location_latitude %}
The approximate location of the respondent at the time the survey was taken.
{% enddocs %}

{% docs location_longitude %}
The approximate location of the respondent at the time the survey was taken.
{% enddocs %}

{% docs progress %}
How far the respondent has progressed through the survey as a percentage out of 100.
{% enddocs %}

{% docs recipient_email %}
Email of the [recipient](https://api.qualtrics.com/ZG9jOjg3NzY2OQ-getting-information-about-distributions#the-recipients-object) if they are a single recipient (not a mailing list or sample).
{% enddocs %}

{% docs recipient_first_name %}
First name of the [recipient](https://api.qualtrics.com/ZG9jOjg3NzY2OQ-getting-information-about-distributions#the-recipients-object) if they are a single recipient (not a mailing list or sample).
{% enddocs %}

{% docs recipient_last_name %}
Last name of the [recipient](https://api.qualtrics.com/ZG9jOjg3NzY2OQ-getting-information-about-distributions#the-recipients-object) if they are a single recipient (not a mailing list or sample).
{% enddocs %}

{% docs recorded_date %}
The point in time when the survey response was recorded.
{% enddocs %}

{% docs start_date %}
The point in time when the survey response was recorded.
{% enddocs %}

{% docs status %}
The type of response.
{% enddocs %}

{% docs user_language %}
The language of the respondent.
{% enddocs %}

{% docs sub_question_key %}
Key of the sub question.
{% enddocs %}

{% docs creation_date %}
The creation date and time of the record, expressed as an ISO 8601 value.
{% enddocs %}

{% docs survey_version_description %}
A user-provided description of the survey version.
{% enddocs %}

{% docs version_id %}
The unique identifier for this survey version.
{% enddocs %}

{% docs published %}
Boolean that, when true, publishes the version.
{% enddocs %}

{% docs publisher_user_id %}
ID of `USER` who published this survey version in your org.
{% enddocs %}

{% docs version_number %}
The version number of this survey.
{% enddocs %}

{% docs was_published %}
Boolean that is true if the survey version was published.
{% enddocs %}

{% docs import_id %}
A unique identifier to recognize this import job of embedded survey data.
{% enddocs %}

{% docs key %}
Key of the embedded survey data element.
{% enddocs %}

{% docs value  %}
Key of the embedded survey data element.
{% enddocs %}

{% docs deduplication_criteria_email %}
Boolean representing if directory contacts are deduped based on email.
{% enddocs %}

{% docs deduplication_criteria_external_data_reference %}
Boolean representing if directory contacts are deduped based on an external data reference. 
{% enddocs %}

{% docs deduplication_criteria_first_name %}
Boolean representing if directory contacts are deduped based on first name.
{% enddocs %}

{% docs deduplication_criteria_last_name %}
Boolean representing if directory contacts are deduped based on last name.
{% enddocs %}

{% docs deduplication_criteria_phone %}
Boolean representing if directory contacts are deduped based on phone number.
{% enddocs %}

{% docs directory_id %}
The directory ID, also known as a pool ID. Example - POOL_012345678901234
{% enddocs %}

{% docs is_default %}
Boolean representing if this directory is the default one for your brand. 

The default directory will be the first directory listed in the dropdown menu in Qualtrics.
{% enddocs %}

{% docs directory_name %}
Name of the directory.
{% enddocs %}

{% docs directory_unsubscribe_date %}
Date and time the user opted out of the directory.
{% enddocs %}

{% docs directory_unsubscribed %}
Boolean indicating whether the contact unsubscribed from all contact from the Directory.
{% enddocs %}

{% docs contact_email %}
Contact's email address. Must be in proper email format.
{% enddocs %}

{% docs email_domain %}
Domain of the contact's email address.
{% enddocs %}

{% docs ext_ref %}
The external reference for the contact.
{% enddocs %}

{% docs contact_first_name %}
Contact's first name.
{% enddocs %}

{% docs contact_id %}
The ID for the contact. Example - CID_012345678901234
{% enddocs %}

{% docs contact_last_name %}
Contact's surname.
{% enddocs %}

{% docs phone %}
Contact's phone number.
{% enddocs %}

{% docs write_blanks %}
Boolean of whether to write blanks(?) or not.
{% enddocs %}

{% docs header_from_email %}
Email from address.
{% enddocs %}

{% docs header_from_name %}
Email from name.
{% enddocs %}

{% docs header_reply_to_email %}
Email reply-to address.
{% enddocs %}

{% docs header_subject %}
Email subject; text or message id (MS_).
{% enddocs %}

{% docs distribution_id %}
The unique Distribution ID.
{% enddocs %}

{% docs message_library_id %}
Library ID of the message.
{% enddocs %}

{% docs message_message_id %}
The ID for the desired library message.
{% enddocs %}

{% docs message_message_text %}
Text of the message to send.
{% enddocs %}

{% docs parent_distribution_id %}
The unique ID of the parent distribution.
{% enddocs %}

{% docs recipient_contact_id %}
The contact ID of the recipient. Can point to `directory_contact` or `core_contact`.
{% enddocs %}

{% docs recipient_library_id %}
Library ID of the message.
{% enddocs %}

{% docs recipient_mailing_list_id %}
The mailing list or contact group associated with the distribution(s). Can point to `directory_mailing_list` or `core_mailing_list`.
{% enddocs %}

{% docs recipient_sample_id %}
The ID for the desired sample. Can point to `directory_sample` or `core_sample` (not included in package).
{% enddocs %}

{% docs request_status %}
The distribution's status. States include `Pending` and `Done`. The Pending state is for email that is scheduled to be sent at a later time.
{% enddocs %}

{% docs request_type %}
The distribution's type. Types include `Invite`, `Reminder`, and `ThankYou`.
{% enddocs %}

{% docs send_date %}
The date and time the request will be or was sent (in ISO 8601 format). Note that this date and time could be in the future if the email distribution is scheduled to send after a delay.
{% enddocs %}

{% docs survey_link_expiration_date %}
The expiration date for the link associated with the survey distribution. Null if `request_type` != `Invite`.
{% enddocs %}

{% docs survey_link_link_type %}
The link type (`Individual`, `Anonymous`, or `Multiple`) for the link associated with the survey distribution. Null if `request_type` != `Invite`.
{% enddocs %}

{% docs survey_link_survey_id %}
The unique survey ID. Will be non-null even if `request_type` != `Invite`. 
{% enddocs %}

{% docs contact_frequency_rule_id %}
The contact frequency Rule ID. Ex - FQ_AAB234234
{% enddocs %}

{% docs contact_lookup_id %}
Optional contact lookup ID for individual distribution.
{% enddocs %}

{% docs opened_at %}
The time a survey was opened by the respondent, will be null if the survey has not been opened.
{% enddocs %}

{% docs response_completed_at %}
The time a response was completed, will be null for uncompleted surveys.
{% enddocs %}

{% docs distribution_response_id %}
The ID of the survey response submitted by this contact. If no survey response has been submitted, this value will be null. If the survey was setup to anonymize responses, then this value will be `Anonymous`.
{% enddocs %}

{% docs response_started_at %}
The time a response was started by the respondent, will be null if survey has not been started.
{% enddocs %}

{% docs sent_at %}
The time a survey was sent to the respondent.
{% enddocs %}

{% docs distribution_status %}
One of ([full descriptions](https://api.qualtrics.com/fc8017650d0b9-distribution-status)):
- `Pending`
- `Success`
- `Error`
- `Opened`
- `Complaint`
- `Skipped`
- `Blocked`
- `Failure`
- `Unknown`
- `SoftBounce`
- `HardBounce`
- `SurveyStarted`
- `SurveyPartiallyFinished`
- `SurveyFinished`
- `SurveyScreenedOut`
- `SessionExpired`
{% enddocs %}

{% docs survey_link %}
The survey link sent with the distribution. This is null when no link was sent.
{% enddocs %}

{% docs survey_session_id %}
An identifier that represents the session in which the respondent interacted with the survey
{% enddocs %}

{% docs mailing_list_id %}
The ID for the mailing list.
{% enddocs %}

{% docs mailing_list_name %}
Name of the mailing list.
{% enddocs %}

{% docs mailing_list_unsubscribed %}
Boolean indicating whether the contact has opted out of receiving email through this mailing list.
{% enddocs %}

{% docs mailing_list_unsubscribe_date %}
Date and time the user opted out of this mailing list.
{% enddocs %}

{% docs mailing_list_contact_id %}
Mailing List Contact ID (different from `contact_id`). ex: `MLRP_*`
{% enddocs %}

{% docs library_id %}
The library ID. Example: `UR_1234567890AbCdE`
{% enddocs %}

{% docs mailing_list_category %}
The library ID. Example: `UR_1234567890AbCdE`
{% enddocs %}

{% docs folder %}
The folder this is placed in.
{% enddocs %}




{% docs embedded_data %}
JSON of  Any extra information you would like recorded in addition to the question responses (from the `survey_embedded_data` source table).
{% enddocs %}

{% docs count_published_versions %}
Number of versions that have been published for this survey.
{% enddocs %}

{% docs count_questions %}
Total number of questions (does not include deleted ones) in the survey.
{% enddocs %}

{% docs avg_response_duration_in_seconds %}
On average, how long it took a respondent to finish a survey in seconds.
{% enddocs %}

{% docs avg_survey_progress_pct %}
On average, how far a respondent has progressed through a survey as a percentage out of 100.
{% enddocs %}

{% docs median_response_duration_in_seconds %}
The median of how long it took a respondent to finish a survey in seconds.
{% enddocs %}

{% docs median_survey_progress_pct %}
The median of how far a respondent has progressed through a survey as a percentage out of 100.
{% enddocs %}

{% docs count_survey_responses %}
Total number of survey responses.
{% enddocs %}

{% docs count_completed_survey_responses %}
Total number of _completed_ survey responses (ie `is_finished=true`).
{% enddocs %}

{% docs count_survey_responses_30d %}
Number of survey responses recorded in the past 30 days.
{% enddocs %}

{% docs count_completed_survey_responses_30d %}
Number of _completed_ survey responses recorded in the past 30 days.
{% enddocs %}

{% docs count_anonymous_survey_responses %}
Number of recorded survey responses distributed anonymously.
{% enddocs %}

{% docs count_anonymous_completed_survey_responses %}
Number of _completed_ recorded survey responses distributed anonymously.
{% enddocs %}

{% docs count_social_media_survey_responses %}
Number of recorded survey responses distributed via [social media](https://www.qualtrics.com/support/survey-platform/distributions-module/social-media-distribution/).
{% enddocs %}

{% docs count_social_media_completed_survey_responses %}
Number of _completed_ survey responses distributed via [social media](https://www.qualtrics.com/support/survey-platform/distributions-module/social-media-distribution/).
{% enddocs %}

{% docs count_personal_link_survey_responses %}
Number of recorded survey responses distributed via [personal links](https://www.qualtrics.com/support/survey-platform/distributions-module/email-distribution/personal-links/).
{% enddocs %}

{% docs count_personal_link_completed_survey_responses %}
Number of _completed_ survey responses distributed via [personal links](https://www.qualtrics.com/support/survey-platform/distributions-module/email-distribution/personal-links/).
{% enddocs %}

{% docs count_qr_code_survey_responses %}
Number of recorded survey responses distributed via [QR codes](https://www.qualtrics.com/support/survey-platform/distributions-module/web-distribution/qr-code/).
{% enddocs %}

{% docs count_qr_code_completed_survey_responses %}
Number of _completed_ survey responses distributed via [QR codes](https://www.qualtrics.com/support/survey-platform/distributions-module/web-distribution/qr-code/).
{% enddocs %}

{% docs count_email_survey_responses %}
Number of recorded survey responses distributed via [email](https://www.qualtrics.com/support/survey-platform/distributions-module/email-distribution/emails-overview/).
{% enddocs %}

{% docs count_email_completed_survey_responses %}
Number of _completed_ survey responses distributed via [email](https://www.qualtrics.com/support/survey-platform/distributions-module/email-distribution/emails-overview/).
{% enddocs %}

{% docs count_sms_survey_responses %}
Number of recorded survey responses distributed via [SMS invite](https://www.qualtrics.com/support/survey-platform/distributions-module/mobile-distributions/sms-surveys/).
{% enddocs %}

{% docs count_sms_completed_survey_responses %}
Number of _completed_ survey responses distributed via [SMS invite](https://www.qualtrics.com/support/survey-platform/distributions-module/mobile-distributions/sms-surveys/).
{% enddocs %}

{% docs count_uncategorized_survey_responses %}
Number of recorded survey responses not distributed via the default channels.
{% enddocs %}

{% docs count_uncategorized_completed_survey_responses %}
Number of _completed_ survey responses not distributed via the default channels.
{% enddocs %}

{% docs publisher_email %}
Email of the `USER` who published the latest survey version.
{% enddocs %}

{% docs creator_email %}
Email of the `USER` who created the object.
{% enddocs %}

{% docs owner_email %}
Email of the `USER` who owns the object.
{% enddocs %}

{% docs is_xm_directory_contact %}
Boolean representing whether the contact came from the XM Directory API endpoint (ie stored in the `directory_contact` table).
{% enddocs %}

{% docs is_research_core_contact %}
Boolean representing whether the contact came from the (to-be-deprecated) Research Core API endpoint (ie stored in the `core_contact` table).
{% enddocs %}

{% docs mailing_list_ids %}
Comma-separated list of mailing list IDs the record is associated with.
{% enddocs %}

{% docs count_surveys_sent_email %}
Distinct surveys sent to the contact via email invite.
{% enddocs %}

{% docs count_surveys_sent_sms %}
Distinct surveys sent to the contact via SMS invite.
{% enddocs %}

{% docs count_surveys_opened_email %}
Distinct surveys opened by the contact via email invite.
{% enddocs %}

{% docs count_surveys_opened_sms %}
Distinct surveys opened by the contact via SMS invite.
{% enddocs %}

{% docs count_surveys_started_email %}
Distinct surveys started by the contact via email invite.
{% enddocs %}

{% docs count_surveys_started_sms %}
Distinct surveys started by the contact via SMS invite.
{% enddocs %}

{% docs count_surveys_completed_email %}
Distinct surveys completed by the contact via email invite.
{% enddocs %}

{% docs count_surveys_completed_sms %}
Distinct surveys completed by the contact via SMS invite.
{% enddocs %}

{% docs total_count_surveys %}
Total distinct surveys distributed.
{% enddocs %}

{% docs total_count_completed_surveys %}
Total distinct surveys completed.
{% enddocs %}

{% docs last_survey_response_recorded_at %}
The most recent point in time when a survey response was recorded.
{% enddocs %}

{% docs first_survey_response_recorded_at %}
The earliest point in time when a survey response was recorded.
{% enddocs %}

{% docs count_mailing_lists_subscribed_to %}
Count of distinct mailing lists the contact is a member of and has not opted out of.
{% enddocs %}

{% docs count_mailing_lists_unsubscribed_from %}
Count of distinct mailing lists that the contact has opted out of receiving emails through.
{% enddocs %}

{% docs count_distinct_emails %}
Count of distinct email addresses in the directory.
{% enddocs %}

{% docs count_distinct_phones %}
Count of distinct phone numbers (stripped of any non-numeric characters) in the directory.
{% enddocs %}

{% docs total_count_contacts %}
Total number of contacts.
{% enddocs %}

{% docs total_count_unsubscribed_contacts %}
Total number of contacts who have unsubscribed from the directory.
{% enddocs %}

{% docs count_contacts_created_30d %}
Number of contacts created in the last 30 days (inclusive) in this directory.
{% enddocs %}

{% docs count_contacts_unsubscribed_30d %}
Number of contacts who have opted out of receiving communications through this directory in the last 30 days (inclusive).
{% enddocs %}

{% docs count_contacts_sent_survey_30d %}
Number of contacts in this directory who have been sent a survey in the past 30 days (inclusive).
{% enddocs %}

{% docs count_contacts_opened_survey_30d %}
Number of contacts in this directory who have been sent a survey in the past 30 days (inclusive) and opened it.

{% enddocs %}

{% docs count_contacts_started_survey_30d %}
Number of contacts in this directory who have been sent a survey in the past 30 days (inclusive)and started it.
{% enddocs %}

{% docs count_contacts_completed_survey_30d %}
Number of contacts in this directory who have been sent a survey in the past 30 days (inclusive) and completed it.
{% enddocs %}

{% docs count_surveys_sent_30d %}
Number of _distinct_ surveys sent to contacts in the past 30 days (inclusive).
{% enddocs %}

{% docs count_mailing_lists %}
Number of mailing lists the exist within the directory.
{% enddocs %}

{% docs parent_distribution_header_subject %}
Email subject; text or message id (MS_) of the parent distribution.
{% enddocs %}

{% docs recipient_mailing_list_name %}
Name of the mailing list associated with the distribution(s).
{% enddocs %}

{% docs owner_first_name %}
First name of the `user` who owns the object.
{% enddocs %}

{% docs owner_last_name %}
Surname of the `user` who owns the object.
{% enddocs %}

{% docs count_contacts_sent_surveys %}
Count of unique contacts who have been sent surveys via the distribution.
{% enddocs %}

{% docs count_contacts_opened_surveys %}
Count of unique contacts who have opened surveys via the distribution.
{% enddocs %}

{% docs count_contacts_started_surveys %}
Count of unique contacts who have started surveys via the distribution.
{% enddocs %}

{% docs count_contacts_completed_surveys %}
Count of unique contacts who have completed surveys via the distribution.
{% enddocs %}

{% docs first_survey_sent_at %}
Timestamp of when the first survey was sent via this distribution.
{% enddocs %}

{% docs last_survey_sent_at %}
Timestamp of when a survey was most recently sent out via this distribution.
{% enddocs %}

{% docs first_survey_opened_at %}
Timestamp of when the first survey was opened via this distribution.
{% enddocs %}

{% docs last_survey_opened_at %}
Timestamp of when a survey was most recently opened via this distribution.
{% enddocs %}

{% docs first_response_completed_at %}
Timestamp of when the first survey was completed via this distribution.
{% enddocs %}

{% docs last_response_completed_at %}
Timestamp of when a survey was most recently completed via this distribution.
{% enddocs %}

{% docs avg_time_to_open_in_seconds %}
Average time difference between when a survey was sent and when it was opened.
{% enddocs %}

{% docs avg_time_to_start_in_seconds %}
Average time difference between when a survey was **sent** and when it was started.
{% enddocs %}

{% docs avg_time_to_complete_in_seconds %}
Average time difference between when a survey was **sent** and when it was completed.
{% enddocs %}

{% docs median_time_to_open_in_seconds %}
Median time difference between when a survey was sent and when it was opened.
{% enddocs %}

{% docs median_time_to_start_in_seconds %}
Median time difference between when a survey was **sent** and when it was started.
{% enddocs %}

{% docs median_time_to_complete_in_seconds %}
Median time difference between when a survey was **sent** and when it was completed.
{% enddocs %}

{% docs current_count_surveys_pending %}
Count of distributed surveys currently pending (the distribution is scheduled but has yet to be sent).
{% enddocs %}

{% docs current_count_surveys_success %}
Count of distributed surveys currently with a status of `success` (the distribution was successfully delivered to the contact).
{% enddocs %}

{% docs current_count_surveys_error %}
Count of distributed surveys currently with a status of `error` (an error occurred while attempting to send the distribution).
{% enddocs %}

{% docs current_count_surveys_opened %}
Count of distributed surveys currently with a status of `opened` (the distribution was opened by the contact).
{% enddocs %}

{% docs current_count_surveys_complaint %}
Count of distributed surveys currently with a status of `complaint` (the contact complained that the distribution was spam).
{% enddocs %}

{% docs current_count_surveys_skipped %}
Count of distributed surveys currently with a status of `skipped` (the contact was skipped due to contact frequency rules or blacklisted contact information).
{% enddocs %}

{% docs current_count_surveys_blocked %}
Count of distributed surveys currently with a status of `blocked` (the distribution failed to send, because the contact blocked it or the email was caught by the spam circuit breaker).
{% enddocs %}

{% docs current_count_surveys_failure %}
Count of distributed surveys currently with a status of `failed` (the distribution failed to be delivered).
{% enddocs %}

{% docs current_count_surveys_unknown %}
Count of distributed surveys currently with a status of `unknown` (the distribution failed for an unknown reason).
{% enddocs %}

{% docs current_count_surveys_softbounce %}
Count of distributed surveys currently with a status of `softbounce` (the distribution bounced but can be retried).
{% enddocs %}

{% docs current_count_surveys_hardbounce %}
Count of distributed surveys currently with a status of `hardbounce` (the distribution bounced and should not be retried).
{% enddocs %}

{% docs current_count_surveys_surveystarted %}
Count of distributed surveys currently with a status of `surveystarted` (the contact started the survey distributed).
{% enddocs %}

{% docs current_count_surveys_surveyfinished %}
Count of distributed surveys currently with a status of `surveyfinished` (the contact submitted a completed survey response).
{% enddocs %}

{% docs current_count_surveys_surveyscreenedout %}
Count of distributed surveys currently with a status of `surveyscreenedout` (the contact screened out while taking the survey).
{% enddocs %}

{% docs current_count_surveys_sessionexpired %}
Count of distributed surveys currently with a status of `sessionexpired` (the contact's survey session has expired).
{% enddocs %}

{% docs current_count_surveys_surveypartiallyfinished %}
Count of distributed surveys currently with a status of `surveypartiallyfinished` (the contact submitted a partially completed survey response).
{% enddocs %}


{% docs date_day %}
Day of activity in your Qualtrics instance. 
{% enddocs %}

{% docs count_contacts_created %}
New contacts created on this day.
{% enddocs %}

{% docs count_contacts_unsubscribed_from_directory %}
Count of contacts that unsubscribed from a directory.
{% enddocs %}

{% docs count_contacts_unsubscribed_from_mailing_list %}
Count of contacts that unsubscribed from a mailing list.
{% enddocs %}

{% docs count_distinct_surveys_responded_to %}
Count of distinct survey templates (ie `survey_id`) that contacts responded to on this day.
{% enddocs %}

{% docs total_count_survey_responses %}
Count of distinct survey responses recorded on this day.
{% enddocs %}

{% docs total_count_completed_survey_responses %}
Count of distinct complete survey responses recorded on this day.
{% enddocs %}

{% docs count_contacts_opened_sent_surveys %}
Count of contacts who opened a survey that was sent on this day.
{% enddocs %}

{% docs count_contacts_started_sent_surveys %}
Count of contacts who started a survey that was sent on this day.
{% enddocs %}

{% docs count_contacts_completed_sent_surveys %}
Count of contacts who completed a survey that was sent on this day.
{% enddocs %}