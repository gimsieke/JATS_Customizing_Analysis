# JATS_Customizing_Analysis 

Finding a “JATS Light Blue” customization by 

* analyzing JATS articles, 
* identifying popular elements and attributes,
* considering sets of articles from a specific publisher or in a specific subject area as de-facto customizings,
* calculating “supersetticity”, a measure for the extent to which customization A is a superset of customization B (2: A is a superset of B; 0: A does not contain any element or attribute of B)
* calculating a quality factor for customization A to serve as a starting point for arriving at customization B by adding/removing elements or attributes (adding is more expensive than removing, thus favoring supersets),
* identifying an optimal customization to derive most other de-facto customizations from

This optimal customizing ideally has significantly fewer elements and attributes than standard Blue or Green. 

It can then be manually tweaked by adding a couple of elements that make it a more perfect superset of publishers’ de-facto customizations, or by adding, for example obscure MathML elements that no one uses but that would be more difficult to strip away than to keep.

The calculations operate on HTML lists for each unit of analysis, be it a single issue of a journal, multiple issues, all issues of a specific subject area, all issues submitted by a single publisher, all issues submitted by multiple publishers in a subject area, or all issues submitted by all publishers.

These HTML lists simply list each element and each attribute that is found in a given collection (= directory), like this:

```xml
<ul id="elements">
   <li>abstract</li>
   <li>addr-line</li>
   <li>aff</li>
   <li>article</li>
   …
   <li>xref</li>
   <li>year</li>
</ul>
<ul id="attributes">
   <li>@article-type</li>
   <li>@content-type</li>
   …
   <li>@rid</li>
   <li>@specific-use</li>
   <li>@xlink:href</li>
   <li>@xml:lang</li>
</ul>
```

You can create these lists by setting up a configuration like the one given in [conf/sample-conf.xml](https://github.com/gimsieke/JATS_Customizing_Analysis/blob/main/conf/sample-conf.xml) and processing this configuration with [xsl/pipeline.xsl](https://github.com/gimsieke/JATS_Customizing_Analysis/blob/main/xsl/pipeline.xsl). 

If you have Saxon 9.8 or newer installed, you can change into the directory in that you cloned this repo and invoke it like this:

```bash
saxon -xsl:xsl/pipeline.xsl -s:conf/sample-conf.xml -o:out.xhtml
```

Replace `saxon` with the name of your Saxon front-end script or with the complete `java` invocation. Replace `conf/sample-conf.xml` with the path and name of your configuration file.

The paths in the configuration file are given relative to the top-level directory of the cloned repo. You may alternatively supply absolute file URIs (not operating system paths, at least not on Windows).

If the directories are organized hierarchically, a distinct HTML list will be created for each subdirectory and its contents. In addition, an HTML list will be created for each classification token.

The categories such as `STEM`, `HUM` (for humanities) or `ECON` are a suggestion. We are open to extending/refining the taxonomy.

If you open JATS_Customizing.xpr in oXygen, you may apply the scenario called `run pipeline on conf file` on your configuration.

The analysis HTML page will open after running the scenario. Without scenario, you need to manually open the file that you specified with the `-o:` option.

This analysis HTML page will of course only cover your input data. 

For us to be able to use your de-facto customization lists as part of the broader, multi-publisher analysis, you need to zip the `cache` folder that was created below the top-level directory and send it to us.

This way, you don’t have to send the actual JATS files to us.
