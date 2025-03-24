<!DOCTYPE html>
	<html lang="${page.lang}" <#if page.lang_dir!?trim?length != 0>dir="${page.lang_dir!}"</#if> >
    <head>

        <title>${page.title}</title>

		<meta charset="UTF-8">
	  	<meta name="viewport" content='${page.viewport!"width=device-width, initial-scale=1.0"}'>
	  	<meta name="author" content='${page.author!?js_string}'>

	  	<meta name="language" content='${page.meta.locale!"en_EN"}'>
	  	<meta name="keywords" content='${page.meta.keywords!?js_string}'>
		<meta name="description" content='${page.meta.description!?js_string}'>

		<meta property="og:url" content=''>
		<meta property="og:site_name" content='${page.site_name!?js_string}'>
		<meta property="fb:app_id" content='${page.fb_app_id!?js_string}'>

		<meta property="og:locale" content='${page.meta.locale!"en_EN"}'>
		<meta property="og:title" content='${page.meta.title!?js_string}'>
		<meta property="og:description" content='${page.meta.description!?js_string}'>
		<meta property="og:type" content='${page.meta.type!"website"}'>

		<#list page.meta.locale_alt as cur_locale_alt>
			<meta property="og:locale:alternate" content='${cur_locale_alt!?js_string}'>
		</#list>

		<#if page.meta.image!?trim?length != 0>
		<meta property="og:image" content='${page.meta.image!}'>
		<meta property="og:image:width" content='${page.meta.image_width!}'>
		<meta property="og:image:height" content='${page.meta.image_height!}'>
		<meta property="og:image:type" content='${page.meta.image_type!}'>
		<meta property="og:image:alt" content='${page.meta.title!?js_string}'>
		</#if>

		<meta name="twitter:site" content='${page.meta.twitter_site!?js_string}'>
		<meta name="twitter:title" content='${page.meta.title!?js_string}'>
		<meta name="twitter:card" content='${page.meta.twitter_card!"summary"}'>

		<!-- page.customMetaTags -->
		${page.customMetaTags!?no_esc}

		<#if page.canonical_url!?trim?length != 0>
        <link rel="canonical" href="${page.canonical_url!}" />
        </#if>

		<!-- page.headTags -->
		${page.headTags!?no_esc}

		<#if page.headCss?trim?length != 0>
		<style type="text/css">
			${page.headCss!?no_esc}
		</style>
		</#if>

		<#if page.headJs?trim?length != 0>
		<script type="text/javascript">
			${page.headJs!?no_esc}
		</script>
		</#if>

    </head>
    <body>
    	<!-- page.body -->
        ${page.body!?no_esc}

		<!-- page.bodyTags -->
        ${page.bodyTags!?no_esc}

		<#if page.bodyCss?trim?length != 0>
		<!-- page.bodyCss -->
        <style type="text/css">
			${page.bodyCss!?no_esc}
		</style>
		</#if>


		<#if page.bodyJs?trim?length != 0>
		<!-- page.bodyJs -->
		<script type="text/javascript">
			${page.bodyJs!?no_esc}
		</script>
		</#if>
    </body>
</html>