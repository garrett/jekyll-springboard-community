---
---

slugify = (name) ->
  # TODO: Enhance slugification
  (name || "").toLowerCase().replace(/[^\w]/g, '-')

formatEvents = (data) ->
  $placeholder = $('#upcoming-template > .upcoming-list').clone()
  $template_date  = $('.upcoming-date', $placeholder)
  $template_event = $('.upcoming-event', $placeholder)
  $more_link  = $('.upcoming-more', '#upcoming-template')

  # Now that we've extracted the template pieces, clear the placeholder
  $placeholder.empty()

  # Grab the more link href for the base event link generation
  base_link = $more_link.find('a').attr('href')

  items_displayed = 0

  # Process each conference
  Object.values(data)
    .sort (a,b) -> a.start > b.start
    .forEach (item) ->
      date = new Date item.start
      $date = $template_date.clone()
      $event = $template_event.clone()

      # TODO: Handle keyword defined by liquid
      keyword = new RegExp 'conf', 'i'

      keyword = undefined

      if keyword
        keyword_match =
          item.description.match(keyword) ||
          item.name.match(keyword) ||
          (item.tag && item.tag.match(keyword))
      else
        keyword_match = true

      month = new Intl.DateTimeFormat(undefined, { month: "short" }).format(date)

      # Insert day and month
      $date
        .find('.day').html(date.getDate()).end()
        .find('.month').html(month).end()
        .attr('title', item.start)

      # Insert event title and link
      $event
        .find('a')
        .html(item.name)
        .attr('title', item.description)
        .attr('href', base_link + '#' + slugify(item.name))

      # Ensure the date has not passed and that it's limited properly
      # TODO: Make iteration # based on site-configured liquid tags
      if date >= Date.now() && items_displayed <  15 && keyword_match
        items_displayed++

        # Add event info to the placeholder
        $placeholder.append($date).append($event)

  # Add finalized event info and the more link to the upcoming section
  $('#upcoming').html($placeholder).append($more_link)

$ ->
  # TODO: Make the URL configurable via liquid
  eventsData = "{{ site.baseurl }}/assets/lib/events.json"

  # Grab and format events
  $.get eventsData, formatEvents
