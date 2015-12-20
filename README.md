# Email Operations

This utility helps you create the hashed email lists needed by various orgs/sites for email matching. As well as allowing you to compare your own organization's email list to a hashed list from another organzation.

Make sure the CSV of email addresses you're about to run through here has CRLF line endings and the first line is the column header "email".

#### Installation

	npm install -g email-list-operations

#### Basic Usage

	eops -o hashed_emails.csv email_list.csv

#### Flags

##### Compare

	-c --compare <file>

Specify a list of hashed emails if you'd like to figure out which emails on your list already exist.

Example:

	eops -o exist.csv -c hashed_list.csv email_list.csv

##### Case

	-e --case <case>

Whether to upper or lower case the email before hashing (upper, lower, as-is). This defaults to "as-is".

##### Header

	-h --header <header>

What the column that should be hashed is labelled within the CSV file. This defaults to "email".

##### Outpt

	-o --output <output>

What filename the resultant list should be output as. If you don't specify this output filename, you'll just get your list printed to the screen.

Example:

	eops -o exist.csv -c hashed_list.csv email_list.csv

##### Hash

	-r --hash <hash>

Which hashing library to utilize. Right now, we only support sha1 and md5. We default to md5.

##### Salt

	-s --salt <salt>

A salt string. Leave this empty to not use a salt.

##### Presets

	-p --preset <preset>

This allows you to specify convenience presets for political services and publications (dailykos, google, demsdotcom, vindico, care2, upworthy) so that you don't have to set the hash and case options.
