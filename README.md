# Web scraping using WWW::Mechanize(Perl) and BeautifulSoup(Python)

Corpora are the indispensable parts of the research in different levels of natural language processing. Undoubtedly Web is the best resource that may help us constructing our corpus. This repository includes a simple scraper for scraping any desired content from a search engine (here, Google).

The idea is simple:

* We do the query in Google of what we are looking for, we grab the result links (for how many pages that we want).

* Then we scrap again the content of the pages that contain what we're looking for via the provided links in the previous step.

* Just a little manipulation and cleaning would be the last step of having some text to append to our corpus.


### Step 1: WWW::Mechanize 
[WWW::Mechanize](http://search.cpan.org/~oalders/WWW-Mechanize-1.86/lib/WWW/Mechanize.pm)  is a Perl module that provides the tools to get access to the sites and to get their content. What makes Mechanize, or Mech in short, so useful is the features that it has, including all HTTP methods, High-level hyperlink and HTML form support, SSL support, automatic cookies, custom HTTP headers, proxies and etc.

The reason that I've not integrated this step with the step 2 is due to the size of the processing. I personally have created an enormous corpus using this technique, so I've prefered to save the output in each step, in order not to repeat the same tasks in the case of having an unpredicted error (that you would see later one).


### Step 2: Scrape content of the links

The python script gets the directoy of the links gathered in the first step and saves the scraped content of each one. 
