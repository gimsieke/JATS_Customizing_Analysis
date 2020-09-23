<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  version="3.0" exclude-result-prefixes="xs rng">
  
  <xsl:mode name="expand-refs" on-no-match="shallow-copy"/>
  
  <xsl:function name="rng:trace-refs" as="element(*)+" cache="yes">
    <!-- The result of this recursive function is a sequence of d
      define elements, potentially starting with a start element.
      If the sequence starts with a start element, it is a sign 
      that the define that was initially passed to the functions
      was referenced in another define that was ultimately referenced
      by the start element.
      If the resulting sequence doesn’t start with a start element,
      it means that the define in question is not reachable by following
      the refs from the start element, which means that the defined construct
      may not appear in documents that are valid wrt the schema that is 
      analyzed. -->
    <xsl:param name="trace" as="element(rng:define)*"/>
    <xsl:param name="def" as="element(*)+"/><!-- define or start -->
    <xsl:variable name="referenced-by" as="element(*)*"
      select="key('ref-by-name', $def/@name, root($def[1]))/(ancestor::rng:define | ancestor::rng:start)"/>
    <xsl:variable name="already-seen" as="element(rng:define)*"
      select="$referenced-by[some $t in $trace satisfies $t is .]"/>
    <xsl:variable name="previously-unseen" as="element(*)*" 
      select="$referenced-by except $already-seen"/>
    <xsl:choose>
      <xsl:when test="exists($previously-unseen/self::rng:start)">
        <xsl:sequence select="($previously-unseen/self::rng:start, $def, $trace)"/>
      </xsl:when>
      <xsl:when test="exists($previously-unseen)">
        <xsl:sequence select="rng:trace-refs(($def, $trace), $previously-unseen)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="($def, $trace)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:key name="ref-by-name" match="rng:ref" use="@name"/>

  <xsl:template match="rng:define" mode="expand-refs_" priority="2">
    <xsl:message select="'Trace: ', rng:trace-refs((), .) ! (string(@name), name())[1]"/>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="rng:define[empty(rng:trace-refs((), .)/self::rng:start)]"
    mode="expand-refs"/>
  
  
</xsl:stylesheet>