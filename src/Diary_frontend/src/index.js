import { Diary_backend } from "../../declarations/Diary_backend";

function updateDiaryEntries(jsonArray) {
  const diaryEntries = document.getElementsByClassName('diary_entry');
  const subjectElements = document.getElementsByClassName('subject');
  const titleElements = document.getElementsByClassName('title');
  const descriptionElements = document.getElementsByClassName('description');

  jsonArray.forEach((entry, index) => {
    const { subject, title, description } = entry;
    if (index < diaryEntries.length) {
      // const subjectValue = Object.keys(subject)[0] || '';
      // subjectElements[index].innerHTML = subjectValue;
      subjectElements[index].innerHTML = subject;
      titleElements[index].innerHTML = title;
      descriptionElements[index].innerHTML = description;
    }
  });
}

function processEntries(jsonArray) {
  const entries = [];

  jsonArray.forEach(({ homework }) => {
    const { description, day, subject, title } = homework;
    entries.push({ description, day, subject, title });
  });

  console.log(entries);
  updateDiaryEntries(entries);
}

const getAllEntries = async () => {
    const jsonArray = await Diary_backend.getAllEntries();
    processEntries(jsonArray);
  };

// document.addEventListener("DOMContentLoaded", getAllEntries);
// Build the DOM

const container = document.getElementById('container');
const landingPageTemplate = document.getElementById('landingPageTemplate');
const diaryAppTemplate = document.getElementById('diaryAppTemplate');
const dashboardTemplate = document.getElementById('dashboardTemplate');

window.addEventListener('load', loadLandingPage);

function loadLandingPage() {
  clearContainer();
  const landingPage = landingPageTemplate.content.cloneNode(true);
  const diaryAppButton = landingPage.querySelector('#diaryAppButton');
  const dashboardButton = landingPage.querySelector('#dashboardButton');
  // const logoDiv = landingPage.querySelector('#logo');
  const logoDiv = document.getElementById('logo');

  diaryAppButton.addEventListener('click', loadDiaryApp);
  dashboardButton.addEventListener('click', loadDashboard);
  logoDiv.addEventListener('click', loadLandingPage);

  container.appendChild(landingPage);
}


function loadDiaryApp() {
  clearContainer();
  const diaryApp = diaryAppTemplate.content.cloneNode(true);
  container.appendChild(diaryApp);
  getAllEntries();
}

function loadDashboard() {
  clearContainer();
  const dashboard = dashboardTemplate.content.cloneNode(true);
  container.appendChild(dashboard);

  // const form = document.getElementById('homeworkForm');
  const setHomeworkButton = document.getElementById('setHomeworkButton');
  setHomeworkButton.addEventListener('click', setHomework);
  
  function setHomework(e) {
    const form = document.getElementById('homeworkForm');
    const inputs = form.querySelectorAll("input");
    const inputDay = document.getElementById('day');
    const homework_day = parseInt(inputDay.value);
    const inputSubject = document.getElementById('subject');
    const homework_subject = inputSubject.value;
    const inputTitle = document.getElementById('title');
    const homework_title = inputTitle.value;
    const inputDescription = document.getElementById('description');
    const homework_description = inputDescription.value;
    // const homework_object = {day:{homework_day},subject:{homework_subject},title:homework_title,description:homework_description};
    const homework_object = {day:homework_day,subject:homework_subject,title:homework_title,description:homework_description};
    console.log(homework_object);
    Diary_backend.setHomework(homework_object);
    inputs.forEach((input) => {
      input.value = "";
    });
    return false;
  }
}

function clearContainer() {
  container.innerHTML = '';
}