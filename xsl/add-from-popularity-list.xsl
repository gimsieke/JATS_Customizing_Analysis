<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xhtml="http://www.w3.org/1999/xhtml" 
  xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">

  <xsl:output method="xhtml" omit-xml-declaration="no" include-content-type="no"/>
  
  <xsl:param name="popularity-list-uri" as="xs:string"/>
  <xsl:param name="maybe" as="xs:boolean" select="false()"/>
  
  <xsl:mode on-no-match="shallow-copy"/>
  
  <xsl:variable name="popularity-list" as="document-node(element(result))" select="doc($popularity-list-uri)"/>
  
  
  <xsl:template match="xhtml:ul[@id = 'elements']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:perform-sort>
        <xsl:sort select="string(.)"/>
        <xsl:sequence select="xhtml:li"/>
        <xsl:apply-templates select="$popularity-list/result/elements/entry[@action = 'add']"/>
        <xsl:if test="$maybe">
          <xsl:apply-templates select="$popularity-list/result/elements/entry[@action = 'maybe-add']"/>
        </xsl:if>
      </xsl:perform-sort>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="xhtml:ul[@id = 'attributes']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:perform-sort>
        <xsl:sort select="string(.)"/>
        <xsl:sequence select="xhtml:li"/>
        <xsl:apply-templates select="$popularity-list/result/attributes/entry[@action = 'add']"/>
        <xsl:if test="$maybe">
          <xsl:apply-templates select="$popularity-list/result/attributes/entry[@action = 'maybe-add']"/>
        </xsl:if>
      </xsl:perform-sort>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="entry[@action = ('add', 'maybe-add')]">
    <li>
      <xsl:if test="parent::attributes">
        <xsl:text>@</xsl:text>
      </xsl:if>
      <xsl:value-of select="string(.)"/>
    </li>
  </xsl:template>
  
  
</xsl:stylesheet>
