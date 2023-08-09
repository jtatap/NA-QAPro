/**
 * Created by samuel on 10/13/20.
 */

public without sharing class NF_MinicardBuilder {

    // Very beginning/end of the minicard payload
    final static String CARD_LIST_START =    '{"minicards":[';
    final static String CARD_LIST_END =      ']}';

    // Fields for individual cards within the overall payload
    final static String CARD_START =        '{"title":';
    final static String CARD_IMGURL =       '"imageUrl":';
    final static String CARD_DESCRIPTION =  '"description":';
    final static String CARD_END =          '}';

    private Integer NUMBER_OF_CARDS = 0;

    public class NF_Minicard {
        // TODO: Create metadata for default values on minicards
        private String TITLE = '';
        private String IMAGE_URL = '';
        private String DESCRIPTION = '';

        public void setTitle(String input) { TITLE = input; }
        public void setImageURL(String imgURL) { IMAGE_URL = imgURL; }
        public void setDescription(String newDesc) { DESCRIPTION = newDesc; }

        public void addLineToTopOfTitle(String additionalTitle) {
            TITLE = additionalTitle + '<br>' + TITLE;
        }
        public void addLineToTitle(String additionalTitle) {
            if (TITLE == '')
                TITLE += additionalTitle;
            else
                    TITLE += '<br>' + additionalTitle;
        }
        public void addLineToDescription() {
            DESCRIPTION += '<br>';
        }

        public void addLineToTopofDescription(String additionalDesc) {
            DESCRIPTION = additionalDesc + '<br>' + DESCRIPTION;
        }

        public void addLineToDescription(String additionalDesc) {
            if (DESCRIPTION == '')
                DESCRIPTION += additionalDesc;
            else
                    DESCRIPTION += '<br>' + additionalDesc;
        }

        /**
         * Read in a template with formatted variables, and the expected values, and generate a minicard body
         * Inputs:
         *      template:   easily-readable card template, format is described as below
         *      params:     key-value pairs
         * Template formatting options:
         *      _varToItalicize_     : transforms the chosen variable to HTML italics
         *      *varToMakeBold*      : transforms the chosen variable to HTML bolded
         *      <varToLink>          : creates a hyperlink with text set to the KEY and link address set to the VALUE
         */
        public void setDescriptionFromTemplate(String template, Map<String, String> params) {

        }

        public String generateBody() {
            String cardBody = CARD_START;
            cardBody += quote(TITLE);
            cardBody += ',';

            // Add image, if available
            if (!String.isBlank(IMAGE_URL)) {
                cardBody += CARD_IMGURL + quote(IMAGE_URL);
                cardBody += ',';
            }

            cardBody += CARD_DESCRIPTION + quote(DESCRIPTION);
            cardBody += CARD_END;

            return cardBody;
        }
    }

    private NF_Minicard[] listOfCards = new List<NF_Minicard>();
    public NF_Minicard latestCard;


    public NF_MinicardBuilder() {
        this.NUMBER_OF_CARDS = 0;
    }

    public NF_Minicard addMinicard() {
        NF_Minicard newCard = new NF_Minicard();
        listOfCards.add(newCard);
        NUMBER_OF_CARDS++;
        latestCard = newCard;
        return newCard;
    }

    public void dropMinicard(Integer index) {
        if (index < NUMBER_OF_CARDS-1 && index >= 0) {
            listOfCards.remove(index);
            NUMBER_OF_CARDS--;
        } else if (index == -1) {
            index = NUMBER_OF_CARDS-1;
            listOfCards.remove(index);
            NUMBER_OF_CARDS--;
        } else {
            Log.push('>> Cannot remove minicard, index invalid!');
            Logger.logDebug();
        }
    }

    public NF_Minicard addMinicard(String newTitle) {
        NF_Minicard newCard = new NF_Minicard();
        newCard.setTitle(newTitle);
        listOfCards.add(newCard);
        NUMBER_OF_CARDS++;
        latestCard = newCard;
        return newCard;
    }

    public String generatePayload() {
        String payload = CARD_LIST_START;
        Integer count = 0;

        for (NF_Minicard card : listOfCards) {
            count++;
            payload += card.generateBody();
            if (count < NUMBER_OF_CARDS) { payload += ','; }
        }

        payload += CARD_LIST_END;
        return payload;
    }

    // Functions to do generic HTML text transformation
    public static String bold(String textToBold) {
        return '<b>' + textToBold + '</b>';
    }
    public static String italic(String textToItalicize) {
        return '<i>' + textToItalicize + '</i>';
    }
    public static String link(String textToLink, String URL) {
        return '<a href=' + URL + ' target=\'_blank\'>' + textToLink + '</a>';
    }
    public static String quote(String textToQuote) {
        return '"' + textToQuote + '"';
    }
    public static String nestedQuote(String textToQuote) {
        return '\\\"' + textToQuote + '\\\"';
    }
}