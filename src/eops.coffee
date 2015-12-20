`#!/usr/bin/env node
`

program = require 'commander'
fs = require 'fs'
csv = require 'csv-parser'
crypto = require 'crypto'
email = require 'email-validator'

in_array = (needle, haystack) ->
  for key in haystack
    if haystack[key] == needle
      return true
  return false

log_lib = () ->
  console.log ''
  console.log 'Most org/sites doing matching want to see samples to know you "did it right". You can send them the below.'
  console.log ''
  console.log "Here's the samples:"
  console.log ''

do_hash = (unhashed, program) ->
  if program.args[0] == 'demsdotcom' || program.args[0] == 'dailykos'
    program.hash = 'md5'
    program.alter = 'upper'
  if program.args[0] == 'google'
    program.hash = 'sha256'
    program.alter = 'lower'
  else if program.args[0] == 'care2' && program.salt
    program.hash = 'sha1'
    program.alter = 'as-is'
    unhashed = program.salt + unhashed
  else if program.args[0] == 'care2' && !program.salt
    console.log 'If you want to do Care2 hashing, you must supply a salt string.'
    console.log ''
    console.log 'For example:'
    console.log 'eops --preset care2 --salt 8zQgWkEKYH4VxHcHN3ecUiFEH emails.csv'
    process.exit 1
  else if program.args[0] == 'vindico'
    program.hash = 'md5'
    program.alter = 'as-is'
  else if program.args[0] == 'upworthy'
    program.hash = 'md5'
    program.alter = 'lower'

  switch program.alter
    when 'upper' then cased_email = unhashed[program.header].toUpperCase()
    when 'lower' then cased_email = unhashed[program.header].toLowerCase()
    when 'as-is' then cased_email = unhashed[program.header]
    else cased_email = unhashed[program.header]
  switch program.hash
    when 'md5' then hashed_email = crypto.createHash('md5').update(cased_email).digest('hex')
    when 'sha1' then hashed_email = crypto.createHash('sha1').update(cased_email).digest('hex')
    when 'sha256' then hashed_email = crypto.createHash('sha256').update(cased_email).digest('hex')
    else hashed_email = crypto.createHash('md5').update(cased_email).digest('hex')

  return hashed_email

attempt_fix = (email) ->
  email = email.replace('.@', '@')
  email = email.replace('..', '.')
  email = email.replace('`', '')
  email = email.replace('\+[a-zA-Z0-9\-\_\+]{0,}\@', '@')
  email = email.replace(/\.com\.com$/, '.com')
  email = email.replace(/\@gnail/, '@gmail')
  email = email.replace(/\@aol\.com\@aol\.com$/, '@aol.com')
  email = email.replace(/\@gmail\.com\@gmail\.com$/, '@gmail.com')
  email = email.replace(/\@yahoo\.com\@yahoo\.com$/, '@yahoo.com')
  email = email.replace(/\@hotmail\.com\@hotmail\.com$/, '@hotmail.com')
  email = email.replace(/\@gmail$/, '@gmail.com')
  email = email.replace(/\@rcn$/, '@rcn.com')
  email = email.replace(/\@aol$/, '@aol.com')
  email = email.replace(/\@ymail$/, '@ymail.com')
  email = email.replace(/\@cox$/, '@cox.net')
  email = email.replace(/\@sbcglobal$/, '@sbcglobal.net')
  email = email.replace(/\@charter$/, '@charter.net')
  email = email.replace(/\@hotmail$/, '@hotmail.com')
  email = email.replace(/\@yahoo$/, '@yahoo.com')
  email = email.replace(/\@msn$/, '@msn.com')

  return email

try
  error_file = fs.statSync('eops_errors.log')
  if program.output && output_file_check.isFile()
    fs.unlinkSync(program.output)
catch e
  # Nada

program
  .version('2.4.0')
  .usage('[options] <emails.csv>')
  .option('-c --compare <file>', 'hashed emails (already_hashed.csv)')
  .option('-e --case <alter>', 'whether to upper or lower case the email before hashing (upper, lower, as-is)', /^(upper|lower|as\-is)$/i, 'as-is')
  .option('-h --header <header>', 'header on column that you want to hash. Defaults to "email".', /^([a-zA-Z0-9]{1,})$/i, 'email')
  .option('-o --output <output>', 'file name (exists.csv)')
  .option('-r --hash <hash>', 'hash library (sha1, md5)', /^(sha|md5)$/i, 'md5')
  .option('-s --salt <salt>', 'salt string. leave empty to not use a salt')
  .option('-p --preset <preset>', 'Convenience preset for poitical services and publications (google, dailykos, demsdotcom, vindico, care2, upworthy)', /^(google|dailykos|demsdotcom|vindico|care2|upworthy)$/i)
  .parse(process.argv)


if !program.args[0]
  console.log 'No file input provided'
else if program.args[0] == 'demsdotcom' || program.args[0] == 'dailykos'
  if program.args[0] == 'demsdotcom'
    console.log 'Democrats.com Hashing'
  else if program.args[0] == 'dailykos'
    console.log 'Daily Kos Hashing'
  log_lib()
  console.log 'someone@someTHing.com'
  console.log 'someone@something.org'
  console.log 'someone@something.net'
  console.log ''
  console.log crypto.createHash('md5').update('someone@someTHing.com'.toUpperCase()).digest('hex')
  console.log crypto.createHash('md5').update('someone@something.org'.toUpperCase()).digest('hex')
  console.log crypto.createHash('md5').update('someone@something.net'.toUpperCase()).digest('hex')
else if program.args[0] == 'google'
  console.log 'Google Hashing'
  log_lib()
  console.log 'someone@someTHing.com'
  console.log 'someone@something.org'
  console.log 'someone@something.net'
  console.log ''
  console.log crypto.createHash('sha256').update('someone@someTHing.com'.toLowerCase()).digest('hex')
  console.log crypto.createHash('sha256').update('someone@something.org'.toLowerCase()).digest('hex')
  console.log crypto.createHash('sha256').update('someone@something.net'.toUpperCase()).digest('hex')
else if program.args[0] == 'care2' && program.salt
  console.log 'Care2 Hashing'
  log_lib()
  console.log 'someone@someTHing.com'
  console.log 'someone@something.org'
  console.log 'someone@something.net'
  console.log ''
  console.log crypto.createHash('sha1').update(program.salt+'someone@something.com').digest('hex')
  console.log crypto.createHash('sha1').update(program.salt+'someone@something.org').digest('hex')
  console.log crypto.createHash('sha1').update(program.salt+'someone@something.net').digest('hex')
else if program.args[0] == 'care2' && !program.salt
  console.log 'If you want to do Care2 hashing, you must supply a salt string.'
  console.log ''
  console.log 'For example:'
  console.log 'eops --preset care2 --salt 8zQgWkEKYH4VxHcHN3ecUiFEH emails.csv'
else if program.args[0] == 'vindico'
  console.log 'Vindico Hashing'
  log_lib()
  console.log 'someone@someTHing.com'
  console.log 'someone@something.org'
  console.log 'someone@something.net'
  console.log ''
  console.log crypto.createHash('md5').update('someone@something.com').digest('hex')
  console.log crypto.createHash('md5').update('someone@something.org').digest('hex')
  console.log crypto.createHash('md5').update('someone@something.net').digest('hex')
else if program.args[0] == 'upworthy'
  console.log 'Upworthy Hashing'
  log_lib()
  console.log 'someone@someTHing.com'
  console.log 'someone@something.org'
  console.log 'someone@something.net'
  console.log ''
  console.log crypto.createHash('md5').update('someone@something.com'.toLowerCase()).digest('hex')
  console.log crypto.createHash('md5').update('someone@something.org'.toLowerCase()).digest('hex')
  console.log crypto.createHash('md5').update('someone@something.net'.toLowerCase()).digest('hex')
else
  if program.compare
    hashed_r = []
    fs.createReadStream program.compare
    .pipe csv()
    .on 'data', (hashed) ->
      hashed_r[hashed_r.length] = hashed[program.header]
    .on 'error', (err) ->
      console.log err
    .on 'end', () ->
      try
        output_file_check = fs.statSync(program.output)
        if program.output && output_file_check.isFile()
          fs.unlinkSync(program.output)
      catch e
        # Nada
      try
        fs.createReadStream(program.args[0])
          .pipe csv()
          .on 'data', (unhashed) ->
            if email.validate(unhashed[program.header])
              to_check = do_hash(unhashed, program)
              for key in hashed_r
                if key == to_check
                  if program.output
                    fs.appendFileSync(program.output, unhashed[program.header].toLowerCase()+"\r\n")
                  else
                    console.log unhashed[program.header].toLowerCase()
            else
              fs.appendFileSync('eops_errors.log', 'This email appears to be invalid: '+unhashed[program.header]+"\r\n")
          .on 'end', () ->
            process.exit 0
          .on 'error', (err) ->
            console.log err
      catch e
        console.log e
  else
    try
      output_file_check = fs.statSync(program.output)
      if program.output && output_file_check.isFile()
        fs.unlinkSync(program.output)
        fs.appendFileSync(program.output, 'email'+"\r\n")
    catch e
      # Nada
    try
      fs.createReadStream program.args[0]
      .pipe csv()
      .on 'data', (unhashed) ->
        unhashed[program.header] = attempt_fix(unhashed[program.header])
        if email.validate(unhashed[program.header])
          hashed_email = do_hash(unhashed, program)
          if program.output
            fs.appendFileSync(program.output, hashed_email+"\r\n")
          else
            console.log hashed_email
        else
          fs.appendFileSync('eops_errors.log', 'This email appears to be invalid: '+unhashed[program.header]+"\r\n")
      .on 'end', () ->
        process.exit 0
      .on 'error', (err) ->
        console.log 'An error occurred:', err
    catch e
      console.log e
