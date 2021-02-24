<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:html="http://www.w3.org/1999/xhtml"
  version="3.0"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all">

  <xsl:output indent="yes" method="xhtml"/>

  <xsl:param name="name" as="xs:string?"/>
  <xsl:param name="storage-location" as="xs:string?"/>
  <xsl:param name="cached" as="xs:boolean?"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template match="html:head">
    <xsl:copy>
      <xsl:apply-templates select="@*, html:title, 
        html:meta[not(@name = ('customization-name[$name]', 'storage-location'[$storage-location], 'cached'[$cached]))]"/>
      <xsl:choose>
        <xsl:when test="$name">
          <meta name="customization-name" content="{$name}"/>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$storage-location">
          <meta name="storage-location" content="{$storage-location}"/>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="$cached">
          <meta name="cached" content="{$cached}"/>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
