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