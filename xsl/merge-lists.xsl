<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">

  <!-- This is meant to merge PMC lists from different batches into a single list,
  by transforming an initial HTML list whose list content will be replaced. --> 

  <xsl:param name="match" as="xs:string"/>
  <xsl:param name="customization-name" as="xs:string"/>
  <xsl:param name="dir-uri" as="xs:string"/>
  <xsl:param name="recurse" as="xs:string" select="'no'"/>
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:output method="xhtml" include-content-type="no"/>
  
  <xsl:variable name="html-lists" select="collection($dir-uri || '?recurse=' || $recurse || ';match=' || $match)"
    as="document-node(element(html:html))+"/>
  
  <xsl:template match="html:meta[@name = 'customization-name']/@content">
    <xsl:attribute name="{name()}" select="$customization-name"/>
  </xsl:template>
  
  <xsl:template match="html:ul[@id = ('attributes', 'elements')]">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:for-each select="sort(distinct-values($html-lists//html:ul[@id = current()/@id]/html:li))">
        <li>
          <xsl:value-of select="."/>
        </li>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>
  
  
</xsl:stylesheet>
