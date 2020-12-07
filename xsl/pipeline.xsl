<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  exclude-result-prefixes="#all">

  <xsl:param name="base-dir-uri" as="xs:string"/>

  <xsl:param name="cache" as="xs:boolean" select="true()"/>

  <xsl:mode name="mark-as-cached" on-no-match="shallow-copy"/>
  <xsl:mode name="create-content-class-lists" on-no-match="shallow-copy"/>

  <xsl:template match="/customization-stats">
    <xsl:variable name="html-lists" as="document-node(element(html:html))*">
      <xsl:apply-templates select="*"/>
    </xsl:variable>
    <xsl:variable name="html-lists" as="document-node(element(html:html))*">
      <xsl:sequence select="$html-lists"/>
      <xsl:for-each-group select="$html-lists[html:html/html:body[@class[not(. = 'schema')]]]" 
        group-by="html:html/html:body/@class">
        <xsl:apply-templates select="." mode="create-content-class-lists">
          <xsl:with-param name="all-lists" as="document-node(element(html:html))+" select="current-group()" tunnel="yes"/>
          <xsl:with-param name="customization-name" as="xs:string" select="current-grouping-key()" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:for-each-group>
    </xsl:variable>
    <xsl:for-each select="$html-lists[not(html:html/html:head/html:meta[@name = 'cached']/@content = 'true')]">
      <xsl:result-document method="xhtml" 
        href="{html:html/html:head/html:meta[@name='storage-location']/@content}">
        <xsl:apply-templates select="." mode="mark-as-cached"/>
      </xsl:result-document>
    </xsl:for-each>
    <xsl:variable name="stats" as="map(xs:string, item())" 
      select="transform(map{
                             'stylesheet-location': 'stats.xsl',
                             'initial-template': xs:QName('main'),
                             'stylesheet-params': map{
                                                       xs:QName('html-docs'): $html-lists,
                                                       xs:QName('base-dir-uri'): $base-dir-uri
                                                     }
                           })"/>
    <xsl:for-each select="map:keys($stats)[not(. = 'output')]">
      <xsl:result-document href="{.}">
        <xsl:sequence select="$stats(.)"/>
      </xsl:result-document>
    </xsl:for-each>
    <xsl:sequence select="$stats?output"/>
  </xsl:template>
  
  <xsl:template match="html:head/html:meta[last()]" mode="mark-as-cached">
    <xsl:next-match/>
    <meta xmlns="http://www.w3.org/1999/xhtml" name="cached" content="true"/>
  </xsl:template>
  
  <xsl:template match="rng">
    <xsl:variable name="file-uri" as="xs:anyURI" select="resolve-uri(@uri, $base-dir-uri || '/')"/>
    <xsl:variable name="html-list-uri" as="xs:string" select="replace($file-uri, '\.rng$', '.xhtml')"/>
    <xsl:choose>
      <xsl:when test="doc-available($html-list-uri)">
        <xsl:sequence select="doc($html-list-uri)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="schema-doc" as="document-node(element(rng:grammar))"
          select="doc($file-uri)"/>
        <xsl:variable name="expand-includes" as="document-node(element(rng:grammar))"
          select="transform(map{'source-node':$schema-doc, 'stylesheet-location': 'rng-expand-includes.xsl'})?output"/>
        <xsl:variable name="expand-refs" as="document-node(element(rng:grammar))"
          select="transform(
                    map{
                      'source-node':$expand-includes, 
                      'stylesheet-location': 'rng-expand-refs.xsl',
                      'initial-mode': xs:QName('expand-refs')
                    }
                  )?output"/>
        <xsl:variable name="html-list" as="document-node(element(html:html))"
          select="transform(
                    map{
                      'source-node':$expand-refs, 
                      'stylesheet-location': 'rng-list.xsl',
                      'stylesheet-params': map{
                                             xs:QName('name'): @name,
                                             xs:QName('storage-location'): $html-list-uri
                                           }
                    }
                  )?output"/>
        <xsl:sequence select="$html-list"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="collection">
    <xsl:variable name="dir-uri" as="xs:anyURI" select="resolve-uri(@uri, $base-dir-uri || '/')"/>
    <xsl:variable name="html-list-uri" as="xs:string" select="replace($dir-uri, '^(.+?/([^/]+))/*$', '$1/$2.xhtml')"/>
    <xsl:choose>
      <xsl:when test="doc-available($html-list-uri)">
        <xsl:sequence select="doc($html-list-uri)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="html-list" as="document-node(element(html:html))"
          select="transform(
                    map{
                      'initial-template': xs:QName('main'), 
                      'stylesheet-location': 'collection-list.xsl',
                      'stylesheet-params': map{
                                                xs:QName('base-dir-uri'): $dir-uri,
                                                xs:QName('name'): @name,
                                                xs:QName('storage-location'): $html-list-uri,
                                                xs:QName('content-class'): @class
                                              }
                    }
                  )?output"/>
        <xsl:sequence select="$html-list"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template match="html:meta[@name='storage-location']/@content" mode="create-content-class-lists">
    <xsl:param name="customization-name" as="xs:string" tunnel="yes"/>
    <xsl:attribute name="{name()}" select="replace(., '^(.+)/(.+)(\.xhtml)$', concat('$1/', $customization-name, '$3'))"/>
  </xsl:template>
  
  <xsl:template match="html:meta[@name='customization-name']/@content" mode="create-content-class-lists">
    <xsl:param name="customization-name" as="xs:string" tunnel="yes"/>
    <xsl:attribute name="{name()}" select="$customization-name"/>
  </xsl:template>
  
  <xsl:template match="html:meta[@name='cached']" mode="create-content-class-lists"/>
  
  <xsl:template match="html:ul[@id = ('attributes', 'elements')]" mode="create-content-class-lists">
    <xsl:param name="all-lists" as="document-node(element(html:html))+" tunnel="yes"/>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:for-each-group select="$all-lists//html:ul[@id = current()/@id]/html:li" group-by="string(.)">
        <xsl:apply-templates select="." mode="#current"/>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
