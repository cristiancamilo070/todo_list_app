const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { Translate } = require('@google-cloud/translate').v2;

admin.initializeApp();
const firestore = admin.firestore();
const translate = new Translate();

exports.updateNoteWithTranslation = functions.firestore
  .document('todo/{noteId}')
  .onUpdate(async (change, context) => {
    const updatedNote = change.after.data();
    const originalLanguage = updatedNote.language;
    const previousNote = change.before.data();
    const previousLanguage = previousNote.language;

  // Verifica si el campo 'language' cambió de 
  // false a true o viceversa 
  if (originalLanguage !== previousLanguage) {
    const originalTitle = updatedNote.title;
    const originalDescription = updatedNote.description;

      try {
        // Detecta el idioma original del título
        const [titleDetection] = await translate.detect(originalTitle);
        const titleUserLanguage = titleDetection.language;

        // Traduce el título al idioma opuesto
        const [titleTranslation] = await translate.translate(originalTitle, titleUserLanguage === 'es' ? 'en' : 'es');

        // Detecta el idioma original de la descripción
        const [descriptionDetection] = await translate.detect(originalDescription);
        const descriptionUserLanguage = descriptionDetection.language;

        // Traduce la descripción al idioma opuesto
        const [descriptionTranslation] = await translate.translate(originalDescription, descriptionUserLanguage === 'es' ? 'en' : 'es');

        // Actualiza la nota con los campos traducidos
        await firestore.collection('todo').doc(context.params.noteId).update({
          titleTranslated: titleTranslation,
          descriptionTranslated: descriptionTranslation,
        });
      } catch (error) {
        console.error('Error during translation:', error);
      }
    }
  });
